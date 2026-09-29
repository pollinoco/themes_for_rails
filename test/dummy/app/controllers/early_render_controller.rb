# frozen_string_literal: true

class EarlyRenderController < ApplicationController
  class << self
    attr_accessor :resolutions
  end
  self.resolutions = 0

  before_action { render :show }
  theme :resolve_theme

  private

  def resolve_theme
    EarlyRenderController.resolutions += 1
    "theme_b"
  end
end
