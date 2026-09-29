# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

require_relative "dummy/config/application"
Rails.application.initialize!

require "rails/test_help"
require "minitest/autorun"

module ThemesOnRailsTestHelper
  def with_config(**settings)
    previous = settings.keys.to_h { |key| [ key, ThemesOnRails.config.public_send(key) ] }
    settings.each { |key, value| ThemesOnRails.config.public_send("#{key}=", value) }
    yield
  ensure
    previous&.each { |key, value| ThemesOnRails.config.public_send("#{key}=", value) }
  end
end

ActiveSupport::TestCase.include(ThemesOnRailsTestHelper)
