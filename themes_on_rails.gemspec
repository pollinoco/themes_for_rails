$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "themes_on_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "themes_on_rails"
  s.version     = ThemesOnRails::VERSION
  s.authors     = ["Chamnap Chhorn"]
  s.email       = ["chamnapchhorn@gmail.com"]
  s.homepage    = "https://github.com/chamnap/themes_on_rails"
  s.summary     = "Adds multi themes support to your Rails 3/4/8 application"
  s.description = "Adds multi themes support to your Rails 3/4/8 application"
  s.license     = "MIT"

  s.required_ruby_version     = '>= 3.0.0'
  s.required_rubygems_version = '>= 2.0.0'

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency "rails", ">= 3.2", "< 9.0"
  s.add_dependency "importmap-rails", ">= 1.0"
  s.add_development_dependency "ammeter", "~> 1.1.2"
  s.add_development_dependency "bundler", "~> 2.0"
end
