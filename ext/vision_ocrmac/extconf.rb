# frozen_string_literal: true

require "swift_gem/mkmf"

SwiftGem::Mkmf.create_swift_makefile(
  "vision_ocrmac/vision_ocrmac",
  package: "VisionOcrmac",
  source_dir: __dir__
)
