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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then build the Swift extension and run tests:

```bash
cd ext/vision_ocrmac && ruby extconf.rb && make && cd ../..
bundle exec rake test
```

## License

MIT.
