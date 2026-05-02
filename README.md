# rb-vision-ocrmac

Ruby binding for Apple Vision OCR (`VNRecognizeTextRequest`) on macOS / Apple Silicon. Calls Apple's on-device text recognition directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

## Requirements

- macOS 12+, Apple Silicon
- Swift 6.3+ (SE-0495 `@c` attribute)
- Ruby 3.2+, Bundler 4.x

Install Swift via [swiftly](https://www.swift.org/install/macos/) — Xcode is not required: `brew install swiftly && swiftly install 6.3 && swiftly use 6.3`.

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

## Reference: pure Swift sample

A self-contained Swift script lives at `examples/vision_ocrmac.swift` for sanity-checking Vision behavior without going through Ruby:

```bash
swift examples/vision_ocrmac.swift path/to/image.png
```

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
