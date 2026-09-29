# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"

class ThemesOnRails::AssetsTest < ActiveSupport::TestCase
  setup do
    @root = Pathname.new(Dir.mktmpdir)
    write "theme_a/assets/stylesheets/theme_a/all.scss", "$c: red;"
    write "theme_a/assets/stylesheets/theme_a/_mixins.scss", "$x: 1;"
    write "theme_a/assets/javascripts/theme_a/all.js", "//= require_tree ."
    write "theme_a/assets/images/theme_a/photo.jpg", "binary"
    write "theme_b/assets/stylesheets/theme_b/all.css", ""
  end

  teardown { FileUtils.remove_entry(@root) }

  test "asset_paths lists the stylesheets, javascripts and images roots" do
    paths = ThemesOnRails::Assets.asset_paths(themes: %w[theme_a], themes_path: @root)

    assert_includes paths, @root.join("theme_a/assets/stylesheets").to_s
    assert_includes paths, @root.join("theme_a/assets/javascripts").to_s
    assert_includes paths, @root.join("theme_a/assets/images").to_s
    assert_not_includes paths, @root.join("theme_a/assets/stylesheets/theme_a").to_s
  end

  test ":entrypoints publishes the logical all.css/all.js of every theme plus extras" do
    list = precompile_list(mode: :entrypoints, extra_entrypoints: %w[theme_a/shop.js])

    assert_equal %w[theme_a/all.js theme_a/all.css theme_b/all.css theme_a/shop.js], list
  end

  test "a list of themes publishes only their entrypoints plus extras" do
    list = precompile_list(mode: [ :theme_b ], extra_entrypoints: %w[theme_a/shop.js])

    assert_equal %w[theme_b/all.css theme_a/shop.js], list
  end

  test ":none keeps extra_entrypoints" do
    assert_equal %w[theme_a/shop.js], precompile_list(mode: :none, extra_entrypoints: %w[theme_a/shop.js])
    assert_empty precompile_list(mode: :none, extra_entrypoints: [])
  end

  test "an unknown mode raises" do
    assert_raises(ArgumentError) { precompile_list(mode: :all, extra_entrypoints: []) }
    assert_raises(ArgumentError) { ThemesOnRails.config.precompile_mode = :all }
  end

  test "the engine adds the dummy entrypoints to config.assets.precompile" do
    precompile = Rails.application.config.assets.precompile

    assert_includes precompile, "theme_a/all.css"
    assert_includes precompile, "theme_a/all.js"
    assert_includes precompile, "theme_b/all.css"
  end

  private

  def write(relative, content)
    path = @root.join(relative)
    FileUtils.mkdir_p(path.dirname)
    File.write(path, content)
  end

  def precompile_list(mode:, extra_entrypoints:)
    ThemesOnRails::Assets.precompile_list(themes: %w[theme_a theme_b], themes_path: @root,
                                          mode: mode, extra_entrypoints: extra_entrypoints)
  end
end
