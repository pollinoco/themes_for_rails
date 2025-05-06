require 'rails/generators'

module ThemesOnRails
  class Engine < ::Rails::Engine
    initializer 'themes_on_rails.action_controller' do |app|
      ActiveSupport.on_load :action_controller do
        include ThemesOnRails::ControllerAdditions
      end
    end

    initializer 'themes_on_rails.load_locales' do |app|
      app.config.i18n.load_path += Dir[Rails.root.join('app/themes/*', 'locales', '**', '*.yml').to_s]
    end

    initializer 'themes_on_rails.assets_path' do |app|
      Dir.glob("#{Rails.root}/app/themes/*/assets/*").each do |dir|
        app.config.assets.paths << dir
      end
      
      # Compatibilidad con Rails 8 - añadir los directorios de assets directamente
      ThemesOnRails.all.each do |theme|
        ["javascripts", "stylesheets", "images"].each do |asset_type|
          asset_path = Rails.root.join("app/themes/#{theme}/assets/#{asset_type}/#{theme}").to_s
          app.config.assets.paths << asset_path if Dir.exist?(asset_path)
        end
      end
    end

    initializer 'themes_on_rails.precompile' do |app|
      themes_root = Pathname.new("#{Rails.root}/app/themes")
      allowed_assets_regex = /^[^\/]+\/assets\/(stylesheets|javascripts)\/[^\/]+\/all((_|-).+)?\.(js|css)$/

      Dir.glob(themes_root.join("*/assets/**/*").to_s).each do |entry|
        next unless File.file?(entry)
        # 1. don't allow nested: theme_a/responsive/all.js
        # 2. allow start_with all_ or all-
        # 3. allow all.js and all.css
        relative_entry = Pathname.new(entry).relative_path_from(themes_root).to_s
        if !%w(.js .css).include?(File.extname(entry)) || relative_entry =~ allowed_assets_regex
          app.config.assets.precompile << entry
        end
      end
      
      # Precompilar assets específicos para Rails 8
      ThemesOnRails.all.each do |theme|
        # Precompilar stylesheets y javascripts principales
        app.config.assets.precompile << "#{theme}/all.js"
        app.config.assets.precompile << "#{theme}/all.css"
      end
    end
    
    # Compatibilidad con Rails 8 - Configuración para nuevos adaptadores de assets
    if Rails.gem_version >= Gem::Version.new('7.0')
      initializer 'themes_on_rails.assets_compatibility' do |app|
        if defined?(Propshaft)
          # Adaptaciones para Propshaft
          ThemesOnRails.all.each do |theme|
            app.config.after_initialize do
              # Asegurar que Propshaft encuentra los assets de los temas
              if Rails.application.assets && Rails.application.assets.respond_to?(:load_path)
                Rails.application.assets.load_path.push(*Dir.glob(Rails.root.join("app/themes/#{theme}/assets/*")))
              end
            end
          end
        elsif defined?(Sprockets)
          # Configuración adicional para Sprockets en Rails 8
          app.config.assets.precompile.push(/(?:\/|\\|\A)all\.(css|js)$/)
        end
      end
    end
  end
end
