# frozen_string_literal: true

require "test_helper"

class ThemesOnRails::ActionControllerTest < ActiveSupport::TestCase
  test "resolves String, Symbol, Proc and plain Symbol themes" do
    controller = Object.new
    def controller.resolver = "from_method"

    assert_equal "theme_a", resolve(controller, "theme_a")
    assert_equal "from_method", resolve(controller, :resolver)
    assert_equal "theme_a", resolve(controller, :theme_a)
    assert_equal "theme_a", resolve(controller, ->(_c) { "theme_a" })
  end

  test "rejects other theme types" do
    assert_raises(ArgumentError) { resolve(Object.new, nil) }
  end

  test "theme_view_path follows themes_path" do
    with_config(themes_path: "/srv/themes") do
      assert_equal "/srv/themes/theme_a/views", ThemesOnRails::ActionController.new(Object.new, "theme_a").theme_view_path
    end
  end

  test "theme does not mutate the options it receives" do
    options = { only: :index, prepend: true }.freeze

    Class.new(ApplicationController) { theme "theme_a", options }

    assert_equal({ only: :index, prepend: true }, options)
  end

  test "declarations are inherited without leaking into the parent" do
    parent = Class.new(ApplicationController) { theme "theme_a" }
    child = Class.new(parent) { theme "theme_b", only: :show }

    assert_equal 1, parent._themes_on_rails_declarations.size
    assert_equal 2, child._themes_on_rails_declarations.size
  end

  private

  def resolve(controller, theme)
    ThemesOnRails::ActionController.new(controller, theme).theme_name
  end
end
