# frozen_string_literal: true

class MultiThemeController < ApplicationController
  theme "theme_a", only: :index
  theme ->(_controller) { "theme_b" }, only: [ :show ]
end
