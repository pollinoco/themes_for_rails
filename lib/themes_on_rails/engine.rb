require "rails/generators"
require "themes_on_rails/assets"

module ThemesOnRails
  class Engine < ::Rails::Engine
    initializer "themes_on_rails.action_controller" do |_app|
      ActiveSupport.on_load :action_controller do
        include ThemesOnRails::ControllerAdditions
      end
    end

    initializer "themes_on_rails.load_locales", after: :load_config_initializers do |app|
      app.config.i18n.load_path += Dir[ThemesOnRails.config.themes_path.join("*", "locales", "**", "*.yml").to_s]
    end

    initializer "themes_on_rails.assets_path", after: :load_config_initializers do |app|
      next unless app.config.respond_to?(:assets)

      ThemesOnRails::Assets.asset_paths.each do |dir|
        app.config.assets.paths << dir
      end
    end

    initializer "themes_on_rails.precompile", after: :load_config_initializers do |app|
      next unless app.config.respond_to?(:assets)
      next if ThemesOnRails.config.precompile_mode == :none
      next unless defined?(Sprockets)

      ThemesOnRails::Assets.precompile_list.each do |logical|
        app.config.assets.precompile << logical
      end
    end

    initializer "themes_on_rails.importmap" do |app|
      app.config.after_initialize do
        next unless defined?(Importmap::Engine)
        next unless Rails.application.respond_to?(:importmap)

        ThemesOnRails.all.each do |theme|
          theme_js_dir = ThemesOnRails.config.themes_path.join(theme, "assets", "javascripts", theme)
          next unless theme_js_dir.directory?
          next unless Rails.application.importmap.respond_to?(:pin_all_from)

          Rails.application.importmap.pin_all_from(
            "app/themes/#{theme}/assets/javascripts/#{theme}",
            under: theme,
            to: "themes/#{theme}"
          )
        end
      end
    end
  end
end
