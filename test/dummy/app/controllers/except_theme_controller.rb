# frozen_string_literal: true

class ExceptThemeController < ApplicationController
  theme "theme_a", except: :show
end
