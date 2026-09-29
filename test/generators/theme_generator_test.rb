# frozen_string_literal: true

require "test_helper"
require "rails/generators/test_case"
require "generators/themes_on_rails/theme_generator"

class ThemesOnRails::ThemeGeneratorTest < Rails::Generators::TestCase
  include ThemesOnRailsTestHelper

  tests ThemesOnRails::Generators::ThemeGenerator
  destination File.expand_path("../../tmp/generator", __dir__)
  setup :prepare_destination

  test "creates the theme skeleton" do
    run_generator %w[shop]

    assert_file "app/themes/shop/views/layouts/shop.html.erb" do |layout|
      assert_match %r{stylesheet_link_tag "shop/all"}, layout
      assert_match %r{javascript_include_tag "shop/all"}, layout
    end
    assert_file "app/themes/shop/assets/stylesheets/shop/all.css"
    assert_file "app/themes/shop/assets/javascripts/shop/all.js"
    assert_file "app/themes/shop/assets/images/shop/.gitkeep"
    assert_file "app/themes/shop/locales/.gitkeep"
  end

  test "warns when precompile_mode leaves the theme out" do
    output = with_config(precompile_mode: %w[other]) { run_generator %w[shop] }

    assert_match(/precompile_mode is \["other"\]/, output)
  end

  test "stays quiet with the default precompile_mode" do
    assert_no_match(/precompile_mode/, run_generator(%w[shop]))
  end
end
