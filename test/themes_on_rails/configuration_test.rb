# frozen_string_literal: true

require "test_helper"

class ThemesOnRails::ConfigurationTest < ActiveSupport::TestCase
  test "all lists the theme directories under themes_path" do
    assert_equal %w[theme_a theme_b], ThemesOnRails.all
  end

  test "configure resets the theme list" do
    ThemesOnRails.configure { |c| c.themes_path = File.expand_path("../fixtures/alt_themes", __dir__) }

    assert_equal %w[theme_a], ThemesOnRails.all
  ensure
    ThemesOnRails.configure { |c| c.themes_path = Rails.root.join("app/themes") }
  end

  test "theme locales are loaded into I18n" do
    assert_equal "Hello from theme_a", I18n.t("theme_a.greeting", locale: :en)
  end
end
