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
    
    # Compatibilidad con importmap-rails
    initializer 'themes_on_rails.importmap', after: 'importmap' do |app|
      if defined?(Importmap::Engine) && Rails.application.respond_to?(:importmap)
        # Asegurar que los módulos de JavaScript de cada tema se registren en importmap
        ThemesOnRails.all.each do |theme|
          theme_js_dir = Rails.root.join("app/themes/#{theme}/assets/javascripts/#{theme}")
          
          if Dir.exist?(theme_js_dir)
            # Registrar cada directorio de JavaScript del tema en importmap
            # Usar el método pin_all_from si está disponible
            if Rails.application.importmap.respond_to?(:pin_all_from)
              Rails.application.importmap.pin_all_from(
                "app/themes/#{theme}/assets/javascripts/#{theme}",
                under: theme,
                to: "themes/#{theme}"
              )
            else
              # Forma manual de pinear archivos individuales si pin_all_from no está disponible
              Dir.glob("#{theme_js_dir}/**/*.js").each do |js_file|
                relative_path = Pathname.new(js_file).relative_path_from(theme_js_dir).to_s
                module_name = "#{theme}/#{File.basename(relative_path, '.js')}"
                file_path = "/assets/themes/#{theme}/#{relative_path}"
                
                begin
                  Rails.application.importmap.pin(module_name, to: file_path)
                rescue => e
                  Rails.logger.warn("No se pudo registrar el módulo #{module_name}: #{e.message}")
                end
              end
            end
            
            # Añadir hooks para que nuevos archivos JavaScript se registren automáticamente
            if Rails.env.development?
              theme_js_pattern = "app/themes/#{theme}/assets/javascripts/#{theme}/**/*.js"
              
              # En desarrollo, vigilar cambios en los archivos JavaScript
              Rails.application.config.file_watcher.new([theme_js_pattern]).tap do |watcher|
                app.reloaders << watcher
                
                # Configurar callback para recargar importmap cuando cambian los archivos
                watcher.on_change do |files|
                  Rails.application.importmap.cache_sweeper.execute_if_updated
                end
              end
            end
          end
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
          # Usar una forma segura de añadir patrones de precompilación
          app.config.assets.precompile.push("all.js", "all.css")
          # Así evitamos el uso de start_with? con expresiones regulares
        end
      end
    end
  end
end
