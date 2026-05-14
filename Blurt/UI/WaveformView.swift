import SwiftUI

struct WaveformView: View {
    @State private var barHeights: [CGFloat]

    private let barCount   = 28
    private let barWidth:  CGFloat = 2.5
    private let barGap:    CGFloat = 3.0
    private let minHeight: CGFloat = 3.0
    private let maxHeight: CGFloat = 40.0

    init() {
        _barHeights = State(initialValue: Array(repeating: 3, count: 28))
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: barGap) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 1.25)
                    .fill(barGradient)
                    .frame(width: barWidth, height: barHeights[i])
            }
        }
        .frame(height: maxHeight)
        .onReceive(AudioRecorder.shared.$amplitude) { amplitude in
            guard case .recording = PillWindowController.shared.pillState else { return }
            updateBars(amplitude: CGFloat(amplitude))
        }
        .onReceive(PillWindowController.shared.$pillState) { state in
            if case .recording = state { return }
            withAnimation(.easeOut(duration: 0.2)) {
                barHeights = Array(repeating: minHeight, count: barCount)
            }
        }
    }

    // MARK: - Bar update

    private func updateBars(amplitude: CGFloat) {
        withAnimation(.spring(response: 0.15, dampingFraction: 0.6)) {
            barHeights = (0..<barCount).map { i in
                // Gaussian bell curve — edges ~30 % of centre, never zero.
                let centre = Double(barCount - 1) / 2.0
                let sigma  = Double(barCount) / 3.0
                let bell   = exp(-pow(Double(i) - centre, 2) / (2 * sigma * sigma))
                let jitter = CGFloat.random(in: 0.55...1.45)
                let h = minHeight + amplitude * (maxHeight - minHeight) * CGFloat(bell) * jitter
                return max(minHeight, min(maxHeight, h))
            }
        }
    }

    // MARK: - Gradient

    private var barGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0x6E / 255.0, green: 0x56 / 255.0, blue: 0xCF / 255.0),
                Color(red: 0x8B / 255.0, green: 0x5C / 255.0, blue: 0xF6 / 255.0),
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
}
