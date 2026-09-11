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
        return [] if mode == :none

        list = []
        themes.each do |theme|
          %w[js css].each do |ext|
            next unless entrypoint_exist?(theme, ext, themes_path: themes_path)

            list << "#{theme}/all.#{ext}"
          end
        end
        list.concat(Array(extra_entrypoints))
        list
      end

      def entrypoint_exist?(theme, ext, themes_path: ThemesOnRails.config.themes_path)
        root = Pathname(themes_path)
        type = ext.to_s == "js" ? "javascripts" : "stylesheets"
        source_exts = ext.to_s == "js" ? %w[js] : %w[css scss sass]
        source_exts.any? do |source_ext|
          root.join(theme, "assets", type, theme, "all.#{source_ext}").file?
        end
      end
    end
  end
end
