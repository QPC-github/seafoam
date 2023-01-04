# frozen_string_literal: true

require_relative "lib/seafoam/version"

Gem::Specification.new do |spec|
  spec.name     = "seafoam"
  spec.version  = Seafoam::VERSION
  spec.summary  = "A tool for working with compiler graphs"
  spec.authors  = ["Chris Seaton"]
  spec.homepage = "https://github.com/Shopify/seafoam"
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/Shopify/seafoam/issues",
    "source_code_uri" => "https://github.com/Shopify/seafoam",
    "allowed_push_host" => "https://rubygems.org",
  }

  spec.files = %x(git ls-files bin lib).split("\n")
  spec.bindir = "bin"
  spec.executables = ["seafoam", "bgv2json", "bgv2isabelle"]

  spec.required_ruby_version = ">= 2.7.0"

  spec.add_development_dependency("rake", "~> 13.0.6")
  spec.add_development_dependency("rspec", "~> 3.8")
  spec.add_development_dependency("rubocop-shopify", ">= 2.9.0")
end
