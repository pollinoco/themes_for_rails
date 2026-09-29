# frozen_string_literal: true

module ThemesOnRails
  class ActionController
    THEME_IVAR = :@_themes_on_rails_theme_name

    Declaration = Struct.new(:theme, :only, :except) do
      def applies_to?(action)
        action = action.to_s
        return only.include?(action) if only
        return !except.include?(action) if except

        true
      end
    end

    attr_reader :theme_name

    class << self
      def apply_theme(controller_class, theme, options = {})
        filter_options = options.slice(:only, :except)
        declaration = Declaration.new(theme, action_names(options[:only]), action_names(options[:except]))
        controller_class._themes_on_rails_declarations += [ declaration ]

        # Rails solo admite un `layout` por clase: la lambda elige la declaración de cada acción.
        controller_class.layout(->(controller) { ThemesOnRails::ActionController.layout_for(controller) })

        filter_method = options[:prepend] ? :prepend_before_action : :before_action
        controller_class.public_send(filter_method, filter_options) do |controller|
          resolver = ThemesOnRails::ActionController
          resolver.apply(controller, declaration) if resolver.declaration_for(controller).equal?(declaration)
        end
      end

      # La última declaración que aplica a la acción gana, también frente a las heredadas.
      def declaration_for(controller)
        controller.class._themes_on_rails_declarations.reverse_each.find do |declaration|
          declaration.applies_to?(controller.action_name)
        end
      end

      def apply(controller, declaration = declaration_for(controller))
        theme_instance = new(controller, declaration.theme)
        controller.instance_variable_set(THEME_IVAR, theme_instance.theme_name)
        controller.prepend_view_path(theme_instance.theme_view_path)
        theme_instance.theme_name
      end

      # `false` (sin layout) en las acciones excluidas, como hacía `layout ..., only:/except:`.
      def layout_for(controller)
        return controller.instance_variable_get(THEME_IVAR) if controller.instance_variable_defined?(THEME_IVAR)

        declaration = declaration_for(controller)
        declaration ? apply(controller, declaration) : false
      end

      private

      def action_names(actions)
        Array(actions).map(&:to_s).freeze if actions
      end
    end

    def initialize(controller, theme)
      @controller = controller
      @theme_name = resolve_theme_name(theme)
    end

    def theme_view_path
      "#{prefix_path}/#{@theme_name}/views"
    end

    def prefix_path
      ThemesOnRails.config.themes_path.to_s
    end

    private

    def resolve_theme_name(theme)
      case theme
      when String then theme
      when Proc   then theme.call(@controller).to_s
      when Symbol then @controller.respond_to?(theme, true) ? @controller.send(theme).to_s : theme.to_s
      else
        raise ArgumentError, "String, Proc, or Symbol, expected for `theme'; you passed #{theme.inspect}"
      end
    end
  end
end
