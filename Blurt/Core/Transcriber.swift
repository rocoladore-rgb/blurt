import Foundation

final class Transcriber: ObservableObject {
    static let shared = Transcriber()

    @Published private(set) var state: TranscriberState = .idle

    // The Whisper object is created on a background queue then stored here on the main thread.
    private var whisper: Whisper?
    private let queue = DispatchQueue(label: "com.blurt.transcriber", qos: .userInitiated)

    var isReady: Bool {
        if case .ready = state { return true }
        return false
    }

    // MARK: - Model file locations

    static let modelDirectory: URL = {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return support.appendingPathComponent("Blurt", isDirectory: true)
    }()

    static let modelURL: URL = modelDirectory.appendingPathComponent("ggml-tiny.en.bin")

    private static let downloadURL = URL(
        string: "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.en.bin"
    )!

    private init() {}

    // MARK: - Public entry point

    /// Call once on app launch. Downloads the model if missing, then loads it.
    func prepare() {
        if FileManager.default.fileExists(atPath: Self.modelURL.path) {
            loadModel()
        } else {
            downloadModel()
        }
    }

    // MARK: - Model loading

    private func loadModel() {
        DispatchQueue.main.async { self.state = .loadingModel }

        // Whisper(fromFileURL:) loads the GGML weights synchronously — keep off main thread.
        queue.async { [weak self] in
            guard let self else { return }
            let w = Whisper(fromFileURL: Self.modelURL)
            DispatchQueue.main.async {
                self.whisper = w
                self.state = .ready
                print("Blurt: whisper model loaded ✓")
            }
        }
    }

    // MARK: - Model download

    private func downloadModel() {
        DispatchQueue.main.async { self.state = .downloading(progress: 0) }
        print("Blurt: whisper tiny.en model not found — downloading (~39 MB)…")

        do {
            try FileManager.default.createDirectory(
                at: Self.modelDirectory, withIntermediateDirectories: true
            )
        } catch {
            DispatchQueue.main.async {
                self.state = .error("Cannot create model directory: \(error.localizedDescription)")
            }
            return
        }

        var request = URLRequest(url: Self.downloadURL)
        request.setValue("Blurt/0.1 macOS", forHTTPHeaderField: "User-Agent")

        let task = URLSession.shared.downloadTask(with: request) { [weak self] tempURL, _, error in
            guard let self else { return }

            if let error {
                DispatchQueue.main.async {
                    self.state = .error("Download failed: \(error.localizedDescription)")
                }
                print("Blurt: model download error — \(error)")
                return
            }

            guard let tempURL else {
                DispatchQueue.main.async { self.state = .error("Download returned no file") }
                return
            }

            do {
                if FileManager.default.fileExists(atPath: Self.modelURL.path) {
                    try FileManager.default.removeItem(at: Self.modelURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: Self.modelURL)
                print("Blurt: model download complete ✓")
                self.loadModel()
            } catch {
                DispatchQueue.main.async {
                    self.state = .error("Failed to save model: \(error.localizedDescription)")
                }
            }
        }

        // KVO progress — keep the observation alive until the task finishes.
        let obs = task.progress.observe(\.fractionCompleted, options: [.new]) { [weak self] prog, _ in
            let pct = prog.fractionCompleted
            DispatchQueue.main.async { self?.state = .downloading(progress: pct) }
            // Coarse console progress every 10 %
            if Int(pct * 100) % 10 == 0 {
                print(String(format: "Blurt: downloading… %3.0f%%", pct * 100))
            }
        }
        objc_setAssociatedObject(task, &Self.progressObsKey, obs, .OBJC_ASSOCIATION_RETAIN)

        task.resume()
    }

    private static var progressObsKey: UInt8 = 0

    // MARK: - Transcription

    /// Transcribes 16 kHz mono Float32 samples (from AudioRecorder.capturedAudio).
    /// Completion is always called on the main thread.
    func transcribe(_ samples: [Float], completion: @escaping (Result<String, Error>) -> Void) {
        guard isReady, let whisper else {
            completion(.failure(TranscriberError.notReady(state)))
            return
        }
        guard !samples.isEmpty else {
            completion(.success(""))
            return
        }

        state = .transcribing

        // SwiftWhisper dispatches to its own thread internally; completion is on an arbitrary thread,
        // so we always hop back to main before delivering the result.
        whisper.transcribe(audioFrames: samples) { [weak self] result in
            DispatchQueue.main.async {
                self?.state = .ready
                switch result {
                case .success(let segments):
                    let text = segments.map(\.text).joined()
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    completion(.success(text))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - State

enum TranscriberState: Equatable {
    case idle
    case downloading(progress: Double)
    case loadingModel
    case ready
    case transcribing
    case error(String)
}

// MARK: - Errors

enum TranscriberError: LocalizedError {
    case notReady(TranscriberState)

    var errorDescription: String? {
        switch self {
        case .notReady(let s): return "Transcriber not ready (state: \(s))"
        }
    }
}
