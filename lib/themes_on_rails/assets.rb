# frozen_string_literal: true

require "pathname"

module ThemesOnRails
  module Assets
    ASSET_TYPES = %w[javascripts stylesheets images].freeze

    class << self
      def asset_paths(themes: ThemesOnRails.all, themes_path: ThemesOnRails.config.themes_path)
        root = Pathname(themes_path)
        themes.flat_map do |theme|
          ASSET_TYPES.map { |type| root.join(theme, "assets", type) }
        end.select(&:directory?).map(&:to_s)
      end

      def precompile_list(themes: ThemesOnRails.all,
                          extra_entrypoints: ThemesOnRails.config.extra_entrypoints,
                          themes_path: ThemesOnRails.config.themes_path,
                          mode: ThemesOnRails.config.precompile_mode)
        list = entrypoints(precompiled_themes(themes, mode), themes_path)
        (list + Array(extra_entrypoints)).uniq
      end

      def entrypoint_exist?(theme, ext, themes_path: ThemesOnRails.config.themes_path)
        root = Pathname(themes_path)
        type = ext.to_s == "js" ? "javascripts" : "stylesheets"
        source_exts = ext.to_s == "js" ? %w[js] : %w[css scss sass]
        source_exts.any? do |source_ext|
          root.join(theme, "assets", type, theme, "all.#{source_ext}").file?
        end
      end

      private

      def precompiled_themes(themes, mode)
        case mode
        when :entrypoints then themes
        when :none        then []
        when Array        then mode.map(&:to_s) & themes
        else
          raise ArgumentError, "precompile_mode must be :entrypoints, :none or an Array of themes; got #{mode.inspect}"
        end
      end

      def entrypoints(themes, themes_path)
        themes.flat_map do |theme|
          %w[js css].filter_map do |ext|
            "#{theme}/all.#{ext}" if entrypoint_exist?(theme, ext, themes_path: themes_path)
          end
        end
      end
    end
  end
end
