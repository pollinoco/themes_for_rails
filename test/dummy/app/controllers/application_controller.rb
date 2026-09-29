# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Todos los controladores de prueba comparten las vistas de `pages/`.
  def self.controller_path
    "pages"
  end

  def index; end

  def show; end
end
