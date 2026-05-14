import AVFoundation
import Accelerate

final class AudioRecorder: ObservableObject {
    static let shared = AudioRecorder()

    // Driven by each tap buffer; used by WaveformView in Phase 7.
    @Published private(set) var amplitude: Float = 0.0
    @Published private(set) var isRecording = false

    // Captured PCM audio, ready for whisper.cpp (16 kHz mono Float32).
    // Safe to read after stopRecording() returns — engine.stop() flushes
    // the audio unit graph before returning, so no tap callbacks can run after.
    private(set) var capturedAudio: [Float] = []

    private let engine = AVAudioEngine()
    private var converter: AVAudioConverter?

    // whisper.cpp requires 16 kHz mono Float32 PCM
    private static let whisperFormat = AVAudioFormat(
        commonFormat: .pcmFormatFloat32,
        sampleRate: 16_000,
        channels: 1,
        interleaved: false
    )!

    private init() {}

    // MARK: - Permission

    /// Checks the current microphone auth status and requests access if needed.
    /// Completion is always called on the main thread.
    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            DispatchQueue.main.async { completion(true) }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            DispatchQueue.main.async { completion(false) }
        }
    }

    // MARK: - Recording lifecycle

    func startRecording() {
        guard !isRecording else { return }

        capturedAudio = []

        let inputNode = engine.inputNode
        let hwFormat = inputNode.outputFormat(forBus: 0)

        guard hwFormat.sampleRate > 0 else {
            print("Blurt: audio input unavailable (no microphone?)")
            return
        }

        converter = AVAudioConverter(from: hwFormat, to: Self.whisperFormat)

        // Use 1024-frame tap buffers (~23 ms at 44.1 kHz) for smooth amplitude updates.
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: hwFormat) { [weak self] buffer, _ in
            self?.process(buffer)
        }

        do {
            try engine.start()
            DispatchQueue.main.async { self.isRecording = true }
        } catch {
            print("Blurt: audio engine failed to start — \(error.localizedDescription)")
            inputNode.removeTap(onBus: 0)
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        // removeTap then stop — engine.stop() flushes in-flight tap callbacks.
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()

        DispatchQueue.main.async {
            self.isRecording = false
            self.amplitude = 0
        }
    }

    // MARK: - Per-buffer processing (called on AVAudioEngine's internal thread)

    private func process(_ hwBuffer: AVAudioPCMBuffer) {
        // RMS on the native-format buffer accurately reflects mic loudness.
        let rms = computeRMS(hwBuffer)
        DispatchQueue.main.async { self.amplitude = rms }

        if let samples = convertToWhisperFormat(hwBuffer) {
            capturedAudio.append(contentsOf: samples)
        }
    }

    private func computeRMS(_ buffer: AVAudioPCMBuffer) -> Float {
        guard let data = buffer.floatChannelData?[0], buffer.frameLength > 0 else { return 0 }
        var rms: Float = 0
        vDSP_rmsqv(data, 1, &rms, vDSP_Length(buffer.frameLength))
        return rms
    }

    private func convertToWhisperFormat(_ input: AVAudioPCMBuffer) -> [Float]? {
        guard let converter else { return nil }

        // Compute output capacity accounting for the sample-rate ratio.
        let ratio = Self.whisperFormat.sampleRate / input.format.sampleRate
        let outCapacity = AVAudioFrameCount(Double(input.frameLength) * ratio + 0.5)
        guard outCapacity > 0,
              let output = AVAudioPCMBuffer(pcmFormat: Self.whisperFormat, frameCapacity: outCapacity)
        else { return nil }

        var error: NSError?
        var inputConsumed = false

        converter.convert(to: output, error: &error) { _, outStatus in
            guard !inputConsumed else {
                outStatus.pointee = .noDataNow
                return nil
            }
            inputConsumed = true
            outStatus.pointee = .haveData
            return input
        }

        guard error == nil,
              let channelData = output.floatChannelData?[0],
              output.frameLength > 0
        else { return nil }

        return Array(UnsafeBufferPointer(start: channelData, count: Int(output.frameLength)))
    }
}
