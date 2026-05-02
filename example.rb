#!/usr/bin/env ruby
# frozen_string_literal: true

# Run with: bundle exec ruby example.rb [<image-path>]
# Build the native extension first: bundle exec rake compile

require_relative "lib/vision_ocrmac"

path = ARGV.first || File.expand_path("test/fixtures/sample_jp.png", __dir__)

puts "image: #{path}"
puts
puts "text:"
puts VisionOcrmac.recognize(path)
