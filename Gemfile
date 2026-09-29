# frozen_string_literal: true

source "https://rubygems.org"

gemspec

rails_version = ENV.fetch("RAILS_VERSION", nil)
rails_requirement = rails_version ? "~> #{rails_version}.0" : ">= 7.1"

gem "actionpack", rails_requirement
gem "actionview", rails_requirement
gem "railties", rails_requirement

gem "minitest"
gem "rake"
gem "rubocop-rails-omakase", require: false
gem "sprockets-rails"
