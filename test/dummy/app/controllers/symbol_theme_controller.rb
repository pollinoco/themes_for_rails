# frozen_string_literal: true

class SymbolThemeController < ApplicationController
  class << self
    attr_accessor :resolutions
  end
  self.resolutions = 0

  theme :resolve_theme

  private

  def resolve_theme
    SymbolThemeController.resolutions += 1
    "theme_b"
  end
end
