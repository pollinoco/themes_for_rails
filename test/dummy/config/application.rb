# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "themes_on_rails"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "themes_on_rails"
    config.logger = Logger.new(nil)
    config.active_support.deprecation = :stderr
    config.action_controller.allow_forgery_protection = false
  end
end
