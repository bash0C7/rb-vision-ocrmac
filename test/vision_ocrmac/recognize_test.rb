# frozen_string_literal: true

require "test_helper"

class VisionOcrmacRecognizeTest < Test::Unit::TestCase
  FIXTURE = File.expand_path("../fixtures/sample_jp.png", __dir__)

  test "recognize returns non-empty OCR text from a sample image" do
    text = VisionOcrmac.recognize(FIXTURE)
    assert_kind_of(String, text)
    assert_false(text.strip.empty?, "Expected non-empty OCR output, got: #{text.inspect}")
    assert(text.include?("rb-vision-ocrmac"), "Expected 'rb-vision-ocrmac' in OCR output, got: #{text.inspect}")
  end
end
