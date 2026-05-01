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

## CLI

The gem ships two CLIs that target the same Vision request.

```bash
# Ruby CLI (installed with the gem)
vision-ocrmac path/to/image.png
```

```bash
# Pure Swift CLI (no Ruby runtime required)
swift examples/vision_ocrmac.swift path/to/image.png
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then build the Swift extension and run tests:

```bash
cd ext/vision_ocrmac && ruby extconf.rb && make && cd ../..
bundle exec rake test
```

## License

MIT.
