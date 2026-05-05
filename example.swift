import Vision
import AppKit
import Foundation

// Run with: xcrun swift example.swift <image-path>
//
// Note: use 'xcrun swift' (Xcode toolchain), not bare 'swift' (swiftly).
// swiftly 6.3's swift interpret mode fails to JIT-link Apple system
// frameworks (Vision, AppKit), so symbol resolution errors at startup.
// Xcode's swift uses dyld for framework linking and works as expected.

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write("usage: xcrun swift example.swift <image-path>\n".data(using: .utf8)!)
    exit(1)
}

let path = CommandLine.arguments[1]
guard let nsImage = NSImage(contentsOfFile: path),
      let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write("failed to load image: \(path)\n".data(using: .utf8)!)
    exit(2)
}

let semaphore = DispatchSemaphore(value: 0)
let request = VNRecognizeTextRequest { request, _ in
    defer { semaphore.signal() }
    guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
    for obs in observations {
        if let str = obs.topCandidates(1).first?.string {
            print(str)
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
        FileHandle.standardError.write("vision timed out after 30s\n".data(using: .utf8)!)
        exit(4)
    }
} catch {
    FileHandle.standardError.write("vision error: \(error)\n".data(using: .utf8)!)
    exit(3)
}
