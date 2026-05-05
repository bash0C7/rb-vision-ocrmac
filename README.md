# rb-vision-ocrmac

Ruby binding for Apple Vision OCR (`VNRecognizeTextRequest`) on macOS / Apple Silicon. Calls Apple's on-device text recognition directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

## Requirements

- macOS 12+, Apple Silicon
- Swift 6.3+ (SE-0495 `@c` attribute) for the library build
- Ruby 3.2+, Bundler 4.x
- **Xcode Command Line Tools** if you want to run `example.swift` (only). The pure-Swift sample script must run under `xcrun swift`; swiftly's 6.3 swift binary cannot JIT-link Apple system frameworks (Vision, AppKit) in interpret mode. The library build itself does not need Xcode CLT.

Install Swift via [swiftly](https://www.swift.org/install/macos/): `brew install swiftly && swiftly install 6.3 && swiftly use 6.3`. Install CLT (only if you want to run the sample): `xcode-select --install`.

## Installation

```bash
bundle add rb-vision-ocrmac
```

```bash
gem install rb-vision-ocrmac
```

## Usage

```ruby
require "vision_ocrmac"

text = VisionOcrmac.recognize("path/to/image.png")
puts text
```

Or open an IRB console with the gem preloaded:

```bash
bundle exec rake console
```

## Preconditions: caller is responsible for image preprocessing

This gem is a **thin pass-through wrapper** around `VNRecognizeTextRequest`. It does no image preprocessing — no rotation, scaling, orientation correction, page splitting, or layout normalization. If Vision can't read the image as-is, `recognize` returns `""`.

Vision has known weak spots that show up in real workloads:

- **Vertical Japanese book pages with densely-packed text columns** — Vision often fails to detect any text regions and returns 0 observations (empty output). Vertical writing is supported in principle, but the region segmentation gives up on book-page layouts where many narrow columns sit side-by-side. Workaround at the caller: rotate the page 90° so columns become rows, or upscale low-resolution scans (≲ 1000px on the long side) before passing the path in.
- **Low-resolution scans** — sub-1000px images sometimes return zero observations even for clean horizontal text. Upscale before calling.
- **Multi-page PDFs / multi-region images** — split into per-page / per-region images upstream; this gem takes one image at a time.
- **Skew, heavy noise, faint text** — deskew / denoise / contrast-boost in the caller.

**Detection of these cases is also the caller's job.** `recognize` returns `""` for both "Vision succeeded but no text found" and "Vision could not segment the image" — the gem does not distinguish them. Callers that need to retry with preprocessing should branch on `text.empty?` and apply their own fallback chain (rotate → retry → upscale → retry → give up).

A missing path is the one failure mode this gem **does** surface as an exception (`Errno::ENOENT`), since that is unambiguously bad input and never a legitimate empty result.

## Reference: pure Swift sample

A self-contained Swift script lives at `example.swift` (repo root) for sanity-checking Vision behavior without going through Ruby:

```bash
xcrun swift example.swift path/to/image.png
```

Use `xcrun swift` (Xcode toolchain), not bare `swift` from swiftly — swiftly 6.3's interpret mode does not JIT-link Apple system frameworks (Vision, AppKit) and fails at startup with symbol-resolution errors. Xcode's swift uses dyld and works as-is.

## Development

```bash
bundle install
bundle exec rake test
```

`rake test` automatically compiles the Swift Package (`swift build -c release`) and links the C bridge into `lib/vision_ocrmac/vision_ocrmac.bundle` before running the spec, via `Rake::ExtensionTask`.

To run only the build step: `bundle exec rake compile`.

## Acknowledgments

Thanks to [@sussan0416](https://github.com/sussan0416) for ["RubyからSwiftを呼ぶ" (2026-04-25)](https://www.docswell.com/s/sussan0416/K7NG3W-2026-04-25-Tram-LT) at [Lightning Talks on Hakodate Tram, RubyKaigi 2026](https://smarthr.connpass.com/event/385269/), which opened up the Ruby × Swift combination for me. The Swift-side recipe — `@_cdecl`, now `@c` per [SE-0495](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0495-cdecl.md), + `strdup` + paired `*_free` — is generalised in [swift_gem](https://github.com/bash0C7/swift_gem); this gem is its first consumer.

## License

MIT.
