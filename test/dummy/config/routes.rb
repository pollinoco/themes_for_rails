# frozen_string_literal: true

Rails.application.routes.draw do
  %w[string_theme symbol_theme child_theme multi_theme except_theme prepend_theme early_render].each do |name|
    get name, to: "#{name}#index"
    get "#{name}/show", to: "#{name}#show"
  end
end
