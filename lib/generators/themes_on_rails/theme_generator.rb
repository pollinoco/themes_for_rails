require "fileutils"

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
      end

      def copy_manifest_files
        copy_file "all.js", "#{theme_javascripts_directory}/all.js"
        copy_file "all.css", "#{theme_stylesheets_directory}/all.css"
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

      def append_sprockets_manifest
        manifest_path = File.join(destination_root, "app/assets/config/manifest.js")
        return unless File.exist?(manifest_path)

        content = File.read(manifest_path)
        return if content.include?("//= link #{theme_name}/all.css")

        File.open(manifest_path, "a") do |f|
          f.puts "" unless content.end_with?("\n")
          f.puts "//= link #{theme_name}/all.css"
          f.puts "//= link #{theme_name}/all.js"
        end
      end

      def create_tailwind_config
        return unless defined?(Tailwindcss)

        template_file = File.join(self.class.source_root, "tailwind.config.js")
        return unless File.exist?(template_file)

        template "tailwind.config.js", "#{theme_directory}/tailwind.config.js"
      end

      def compile_css
        return unless defined?(Tailwindcss)
        return unless File.exist?("#{theme_directory}/tailwind.config.js")

        say "Compilando CSS para el tema #{theme_name}...", :green

        theme_css_path = "#{theme_stylesheets_directory}/all.css"
        theme_output_path = "app/assets/builds/#{theme_name}.css"

        FileUtils.mkdir_p(File.join(destination_root, "app/assets/builds"))

        system "tailwindcss", "-i", theme_css_path, "-o", File.join(destination_root, theme_output_path).to_s, "-c", "#{theme_directory}/tailwind.config.js"

        say "CSS compilado en #{theme_output_path}", :green
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

        def theme_stylesheets_directory
          "#{theme_directory}/assets/stylesheets/#{theme_name}"
        end

        def theme_locales_directory
          "#{theme_directory}/locales"
        end
    end
  end
end
