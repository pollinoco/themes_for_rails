# frozen_string_literal: true

require_relative "lib/themes_on_rails/version"

Gem::Specification.new do |spec|
  spec.name        = "themes_on_rails"
  spec.version     = ThemesOnRails::VERSION
  spec.authors     = [ "Chamnap Chhorn", "Camilo Sánchez" ]
  spec.email       = [ "chamnapchhorn@gmail.com", "info@caxtor.co" ]
  spec.homepage    = "https://github.com/pollinoco/themes_for_rails"
  spec.summary     = "Multi-theme support for Rails 7.1+ applications"
  spec.description = "Per-controller themes for Rails: theme views and layouts, theme locales and " \
                     "Sprockets entrypoints (<theme>/all.css, <theme>/all.js)."
  spec.license     = "MIT"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "rubygems_mfa_required" => "true"
  }

  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir["lib/**/*", "CHANGELOG.md", "MIT-LICENSE", "README.md"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "actionpack", ">= 7.1", "< 9"
  spec.add_dependency "actionview", ">= 7.1", "< 9"
  spec.add_dependency "railties",   ">= 7.1", "< 9"
end
