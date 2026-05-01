# frozen_string_literal: true

require_relative "lib/vision_ocrmac/version"

Gem::Specification.new do |spec|
  spec.name = "rb-vision-ocrmac"
  spec.version = VisionOcrmac::VERSION
  spec.authors = ["bash0C7"]
  spec.email = ["ksb.4038.nullpointer+github@gmail.com"]

  spec.summary = "Ruby binding for Apple Vision OCR (VNRecognizeTextRequest) on macOS"
  spec.description = "Calls Apple Vision framework's text recognition from Ruby on macOS / Apple Silicon. Built on top of swift_gem."
  spec.homepage = "https://github.com/bash0C7/rb-vision-ocrmac"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/bash0C7/rb-vision-ocrmac"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "swift_gem"
end
