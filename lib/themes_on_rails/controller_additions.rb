# frozen_string_literal: true

module ThemesOnRails
  module ControllerAdditions
    extend ActiveSupport::Concern

    included do
      class_attribute :_themes_on_rails_declarations, instance_accessor: false, instance_predicate: false, default: []
    end

    class_methods do
      def theme(theme, options = {})
        ThemesOnRails::ActionController.apply_theme(self, theme, options)
      end
    end
  end
end
