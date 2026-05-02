# CLAUDE.md — rb-vision-ocrmac

## Position

Ruby native binding for Apple Vision framework (`VNRecognizeTextRequest`). The first consumer of `bash0C7/swift_gem` and a reference implementation of the Swift-extension gem pattern. Called by `archives_go_jp_searcher`'s `VisionStrategy` via `VisionOcrmac.recognize(path)`.

## Core design principles

1. Thin wrapper. Pass-through Vision API. One image → one string (newline separator). Option expansion (multiple-language switching, OCR engine selection, confidence filtering, etc.) is intentionally not added until needed.
2. Fixed ja-JP + en-US, `.accurate`, `usesLanguageCorrection`. Changes go through new API methods; never break existing behavior.
3. 30s timeout, failure represented as an empty string. Does not raise exceptions; the consumer (e.g. `VisionStrategy`) handles `nil` and falls back.
4. C bridge string handoff. Swift allocates with `strdup`, C frees via `vision_ocrmac_free`. Bridge function signatures fixed at `UnsafePointer<CChar>` ↔ `UnsafeMutablePointer<CChar>`.
5. Scaffold parity. `swift_gem new rb-vision-ocrmac` produces a skeleton whose only diffs against this repo are the implementation body, fixtures, and build artifacts. Other diffs must be reconciled to the scaffold.

## Architecture

```
[caller (Ruby): archives_go_jp_searcher's VisionStrategy etc.]
  │
  │   VisionOcrmac.recognize(path) → String
  ▼
lib/vision_ocrmac.rb            ← requires the ext + module declaration
  │
  ▼
ext/vision_ocrmac/vision_ocrmac.c   ← rb_define_singleton_method
  │
  │   vision_ocrmac_recognize(c_path)
  ▼
ext/vision_ocrmac/Sources/VisionOcrmac/VisionOcrmacBridge.swift   ← @c (SE-0495)
  │
  │   performRecognize(path: String) → String
  ▼
ext/vision_ocrmac/Sources/VisionOcrmac/VisionOcrmac.swift   ← NSImage + VNRecognizeTextRequest
  │
  ▼
[Apple Vision framework]
```

## Module boundaries

| Layer | Responsibility |
|---|---|
| `lib/vision_ocrmac.rb` | `require_relative "vision_ocrmac/vision_ocrmac"` to load the .bundle; host of `module VisionOcrmac` |
| `ext/vision_ocrmac/vision_ocrmac.c` | `Init_vision_ocrmac` exposes `VisionOcrmac.recognize`; copies Swift-returned `char*` into a Ruby UTF-8 String via `rb_utf8_str_new_cstr`, then calls `vision_ocrmac_free` |
| `VisionOcrmacBridge.swift` | C ABI export via `@c` (SE-0495). Calls `performRecognize` and returns a C string via `strdup` |
| `VisionOcrmac.swift` | NSImage load → `VNImageRequestHandler.perform` → `VNRecognizedTextObservation.topCandidates(1)` → newline join. `DispatchSemaphore` enforces the 30s timeout |
| `ext/vision_ocrmac/extconf.rb` | `SwiftGem::Mkmf.create_swift_makefile("vision_ocrmac/vision_ocrmac", package: "VisionOcrmac", source_dir: __dir__)` |
| `example.rb` | Ruby sample script: `bundle exec ruby example.rb [<path>]`. Calls `VisionOcrmac.recognize` and prints the result |
| `example.swift` | Pure-Swift sample script: `swift example.swift <path>`. Ruby-free, kept as a Vision-behavior reference (not distributed as a CLI) |
| `Rakefile` | `Rake::ExtensionTask("vision_ocrmac")` + `task test: :compile` for one-shot build-and-test. `task console: :compile` for IRB (`bundle exec rake console`) |

## Build flow

`bundle exec rake test` in one shot:

1. `Rake::ExtensionTask` invokes `extconf.rb` from `tmp/arm64-darwin24/vision_ocrmac/<ruby-ver>/`
2. `swift_gem`'s `create_swift_makefile` runs `swift build -c release --package-path <ext>/vision_ocrmac`
3. The mkmf-generated Makefile compiles `vision_ocrmac.c` and copies the resulting `.bundle` to `lib/vision_ocrmac/vision_ocrmac.bundle`
4. test-unit runs `test/vision_ocrmac/recognize_test.rb` (asserts that real-image OCR contains "rb-vision-ocrmac")

`source_dir: __dir__` in extconf.rb absorbs rake-compiler's cwd switch (see `swift_gem/CLAUDE.md` for details).

To build only: `bundle exec rake compile`. Clean rebuild: `bundle exec rake clean clobber compile`.

## Usage / why no CLI

Used as a Ruby library: callers invoke `VisionOcrmac.recognize(path) → String`. **A Ruby CLI (exe/) is intentionally not provided**:

- Production callers (e.g. `archives_go_jp_searcher`'s `VisionStrategy`) call `recognize` directly inside their Ruby process; an external-process CLI would only add startup cost
- For interactive checks, `bundle exec rake console` starts IRB with the gem auto-loaded (and the ext built first via dependency)
- `example.rb` at the root is a quick Ruby smoke-test: `bundle exec ruby example.rb [<path>]`
- `example.swift` at the root is a minimal pure-Swift sample script for verifying Vision behavior without Ruby. It is not packaged as a CLI

## TDD discipline

- t-wada style: RED → GREEN → REFACTOR each as an independent commit (per global CLAUDE.md)
- test-unit. `bundle exec rake test`
- Real fixture: `test/fixtures/sample_jp.png`. Asserts that Vision OCR returns text containing "rb-vision-ocrmac"
- No standalone Swift XCTest target — the Ruby-side integration is enough; the shell-out cost of a separate Swift test target is not justified
- Scaffold-regen check: when `swift_gem` changes, run `swift_gem new rb-vision-ocrmac` into a tmpdir and diff to keep parity

## Related projects

- `~/dev/src/github.com/bash0C7/swift_gem` — framework parent. extconf.rb calls `SwiftGem::Mkmf.create_swift_makefile`. Scaffold parity is anchored here
- `~/dev/src/github.com/bash0C7/archives_go_jp_searcher` — first caller. `VisionStrategy#default_run` injects `VisionOcrmac.method(:recognize)` as its runner

## Environment requirements

- macOS 12+ (`Package.swift` declares `.macOS(.v12)`, required by Vision framework)
- Apple Silicon (arm64-darwin) assumed. Intel Mac SPM build / rpath assumptions are not verified
- Swift 6.3+ (`Package.swift`'s `swift-tools-version`; required for SE-0495 `@c`). Install via [swiftly](https://www.swift.org/install/macos/).
- Ruby 3.2+, bundler 4.x, rake-compiler 1.2+
- During development, `Gemfile` references swift_gem via `gem "swift_gem", path: "../swift_gem"` (interim until publish)
- `Gemfile.lock` is library-style: not git-tracked (in `.gitignore`)

## Prohibitions

- No Python source (per global CLAUDE.md)
- Do not git-track `Gemfile.lock` (library; the consumer's lock wins)
- Do not promise thread safety for concurrent `recognize` calls — the internal `DispatchSemaphore` may misbehave. Add an explicit lock if needed
- Do not split PDFs / multi-page images here — leave that to callers (e.g. archives_go_jp_searcher)
- Do not cache, normalize, or post-process OCR results here — same as above
- Commit messages in English, conventional commits style (per global CLAUDE.md)
- `.claude/` is committed (per global CLAUDE.md)
