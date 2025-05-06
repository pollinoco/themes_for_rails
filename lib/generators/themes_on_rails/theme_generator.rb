require 'fileutils'

module ThemesOnRails
  module Generators
    class ThemeGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      argument    :theme_name, type: :string
      desc        "Creates a new theme"

     def create_theme_directory
        empty_directory theme_views_layout
        empty_directory theme_images_directory
        empty_directory theme_javascripts_directory
        empty_directory theme_stylesheets_directory
        empty_directory theme_locales_directory
        create_file     "#{theme_images_directory}/.gitkeep", nil
        create_file     "#{theme_locales_directory}/.gitkeep", nil
        
        # Directorio de componentes para importmap-rails
        empty_directory theme_components_directory
      end

      def copy_manifest_files
        template "all.js", "#{theme_javascripts_directory}/all.js"
        template "all.css", "#{theme_stylesheets_directory}/all.css"
        
        # Archivo de componente de ejemplo para importmap-rails
        template "theme-component.js", "#{theme_components_directory}/theme-component.js"
      end

      def copy_layout_file
        template_engine = Rails.configuration.app_generators.rails[:template_engine]
        if template_engine == :liquid
          template "layout.html.liquid", "#{theme_views_layout}/#{theme_name}.liquid"
        elsif template_engine == :haml
          template "layout.html.haml", "#{theme_views_layout}/#{theme_name}.html.haml"
        else
          template "layout.html.erb", "#{theme_views_layout}/#{theme_name}.html.erb"
        end
      end

      def create_tailwind_config
        if defined?(Tailwindcss)
          template "tailwind.config.js", "#{theme_directory}/tailwind.config.js"
        end
      end

      def create_importmap_pin
        if defined?(Importmap) && Rails.application.respond_to?(:importmap)
          say "Configurando importmap para el tema #{theme_name}...", :green
          say ""
          say "Para añadir manualmente el tema a tu importmap, añade lo siguiente a config/importmap.rb:", :green
          say "  pin_all_from \"app/themes/#{theme_name}/assets/javascripts/#{theme_name}\", under: \"#{theme_name}\", to: \"themes/#{theme_name}\"", :green
          say ""
          
          # Intentar añadir automáticamente la configuración al importmap si existe
          importmap_file = Rails.root.join("config/importmap.rb")
          if File.exist?(importmap_file)
            say "Intentando añadir automáticamente la configuración a importmap.rb...", :yellow
            
            importmap_content = File.read(importmap_file)
            pin_code = "\n# Tema: #{theme_name}\npin_all_from \"app/themes/#{theme_name}/assets/javascripts/#{theme_name}\", under: \"#{theme_name}\", to: \"themes/#{theme_name}\"\n"
            
            if !importmap_content.include?("app/themes/#{theme_name}/assets/javascripts")
              File.write(importmap_file, importmap_content + pin_code)
              say "✅ Configuración añadida correctamente a importmap.rb", :green
            else
              say "La configuración ya existe en importmap.rb", :yellow
            end
          end
        end
      end
      
      def compile_css
        if defined?(Tailwindcss) && File.exist?("#{theme_directory}/tailwind.config.js")
          say "Compilando CSS para el tema #{theme_name}...", :green
          
          theme_css_path = "#{theme_stylesheets_directory}/all.css"
          theme_output_path = "app/assets/builds/#{theme_name}.css"
          
          # Asegurarse de que el directorio de salida exista
          FileUtils.mkdir_p(Rails.root.join("app/assets/builds"))
          
          # Ejecutar Tailwind CLI para compilar el CSS
          system "tailwindcss", "-i", theme_css_path, "-o", Rails.root.join(theme_output_path).to_s, "-c", "#{theme_directory}/tailwind.config.js"
          
          say "CSS compilado en #{theme_output_path}", :green
          say "Recuerda añadir este archivo a tu asset pipeline o Propshaft", :green
          
          # Para Propshaft, recordatorio adicional
          if defined?(Propshaft)
            say "Asegúrate de que app/assets/builds esté en tu ruta de búsqueda de assets", :green
          end
        end
      end

      private

        def theme_directory
          "app/themes/#{theme_name}"
        end

        def theme_views_layout
          "#{theme_directory}/views/layouts"
        end

        def theme_images_directory
          "#{theme_directory}/assets/images/#{theme_name}"
        end

        def theme_javascripts_directory
          "#{theme_directory}/assets/javascripts/#{theme_name}"
        end
        
        def theme_components_directory
          "#{theme_javascripts_directory}/components"
        end

        def theme_stylesheets_directory
          "#{theme_directory}/assets/stylesheets/#{theme_name}"
        end

        def theme_locales_directory
          "#{theme_directory}/locales"
        end
    end
  end
end
