# rb-vision-ocrmac

Ruby binding for Apple Vision OCR (`VNRecognizeTextRequest`) on macOS / Apple Silicon. Calls Apple's on-device text recognition directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

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

## License

MIT.
