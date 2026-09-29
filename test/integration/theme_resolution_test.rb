# frozen_string_literal: true

require "test_helper"

class ThemeResolutionTest < ActionDispatch::IntegrationTest
  setup do
    SymbolThemeController.resolutions = 0
    EarlyRenderController.resolutions = 0
  end

  test "a String theme renders the theme layout and views" do
    get "/string_theme"

    assert_layout "theme_a"
    assert_view "theme_a"
  end

  test "the theme falls back to app/views when it lacks a template" do
    get "/string_theme/show"

    assert_layout "theme_a"
    assert_view "application"
  end

  test "a Symbol theme calls its method once per request" do
    get "/symbol_theme"

    assert_layout "theme_b"
    assert_view "theme_b"
    assert_equal 1, SymbolThemeController.resolutions
  end

  test "a subclass theme overrides the inherited one without resolving it" do
    get "/child_theme"

    assert_layout "theme_a"
    assert_view "theme_a"
    assert_equal 0, SymbolThemeController.resolutions
  end

  test "several declarations with only pick the theme per action" do
    get "/multi_theme"
    assert_layout "theme_a"
    assert_view "theme_a"

    get "/multi_theme/show"
    assert_layout "theme_b"
    assert_view "theme_b"
  end

  test "excluded actions render without layout, as with layout only/except" do
    get "/except_theme"
    assert_layout "theme_a"

    get "/except_theme/show"
    assert_view "application"
    assert_select "main", count: 0
  end

  test "prepend: true applies the theme before the other before_actions" do
    get "/prepend_theme"

    assert_equal Rails.root.join("app/themes/theme_a/views").to_s, response.headers["X-First-View-Path"]
    assert_layout "theme_a"
  end

  test "the layout resolves the theme when a previous before_action already rendered" do
    get "/early_render"

    assert_layout "theme_b"
    assert_equal 1, EarlyRenderController.resolutions
  end

  test "views come from a custom themes_path" do
    with_config(themes_path: File.expand_path("../fixtures/alt_themes", __dir__)) do
      get "/string_theme"
    end

    assert_layout "alt_theme_a"
    assert_view "application"
  end

  private

  def assert_layout(name)
    assert_select "main[data-layout=?]", name
  end

  def assert_view(name)
    assert_select "p[data-view=?]", name
  end
end
