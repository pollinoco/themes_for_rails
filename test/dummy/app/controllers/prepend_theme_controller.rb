# frozen_string_literal: true

class PrependThemeController < ApplicationController
  before_action :expose_first_view_path
  theme "theme_a", prepend: true

  private

  def expose_first_view_path
    response.set_header("X-First-View-Path", view_paths.first.to_s)
  end
end
