import Vision
import AppKit
import Foundation

func performRecognize(path: String) -> String {
    guard let nsImage = NSImage(contentsOfFile: path),
          let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        return ""
    }

    var resultLines: [String] = []
    let semaphore = DispatchSemaphore(value: 0)

    let request = VNRecognizeTextRequest { request, _ in
        defer { semaphore.signal() }
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        for obs in observations {
            if let str = obs.topCandidates(1).first?.string {
                resultLines.append(str)
            }
        }
    }
    request.recognitionLanguages = ["ja-JP", "en-US"]
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
        let deadline = DispatchTime.now() + .seconds(30)
        if semaphore.wait(timeout: deadline) == .timedOut {
            return ""
        }
    } catch {
        return ""
    }

    return resultLines.joined(separator: "\n")
}
