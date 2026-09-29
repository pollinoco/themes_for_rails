# frozen_string_literal: true

require "active_support"
require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "pathname"
require "themes_on_rails/version"
require "themes_on_rails/engine"

module ThemesOnRails
  autoload :ActionController,    "themes_on_rails/action_controller"
  autoload :ControllerAdditions, "themes_on_rails/controller_additions"
  autoload :Assets,              "themes_on_rails/assets"

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
      @all = nil
    end

    def all
      @all ||= begin
        root = Pathname(config.themes_path)
        if root.exist?
          root.children.select(&:directory?).map { |p| p.basename.to_s }.reject { |n| n.start_with?(".") }.sort
        else
          []
        end
      end
    end

    def reset!
      @all = nil
      @config = nil
    end
  end

  class Configuration
    attr_accessor :extra_entrypoints
    attr_reader :themes_path, :precompile_mode

    def initialize
      @themes_path = default_themes_path
      @precompile_mode = :entrypoints
      @extra_entrypoints = []
    end

    def themes_path=(path)
      @themes_path = Pathname(path)
    end

    # :entrypoints -> #{theme}/all.js y #{theme}/all.css de todos los themes que los tengan
    # :none        -> ningún entrypoint de theme
    # %w[a b]      -> solo los entrypoints de esos themes
    # `extra_entrypoints` se añade en los tres casos.
    def precompile_mode=(mode)
      unless %i[entrypoints none].include?(mode) || mode.is_a?(Array)
        raise ArgumentError, "precompile_mode must be :entrypoints, :none or an Array of themes; got #{mode.inspect}"
      end

      @precompile_mode = mode
    end

    private

    def default_themes_path
      if defined?(Rails) && Rails.respond_to?(:root) && Rails.root
        Rails.root.join("app/themes")
      else
        Pathname.new("app/themes")
      end
    end
  end
end
