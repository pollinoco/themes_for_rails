require "themes_on_rails/version"
require "themes_on_rails/engine"
require "active_support/concern"
require "pathname"

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
    attr_accessor :precompile_mode, :extra_entrypoints
    attr_reader :themes_path

    def initialize
      @themes_path = default_themes_path
      # :entrypoints = solo #{theme}/all.js y #{theme}/all.css si existen
      # :none        = la gem no toca config.assets.precompile (el host usa manifest.js)
      @precompile_mode = :entrypoints
      @extra_entrypoints = []
    end

    def themes_path=(path)
      @themes_path = Pathname(path)
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
