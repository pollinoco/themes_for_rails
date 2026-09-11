require "spec_helper"
require "tmpdir"
require "fileutils"
require "pathname"

describe ThemesOnRails::Assets do
  let(:themes_root) { Pathname.new(Dir.mktmpdir) }

  before do
    FileUtils.mkdir_p(themes_root.join("theme_a/assets/stylesheets/theme_a"))
    FileUtils.mkdir_p(themes_root.join("theme_a/assets/javascripts/theme_a"))
    FileUtils.mkdir_p(themes_root.join("theme_a/assets/images/theme_a"))
    File.write(themes_root.join("theme_a/assets/stylesheets/theme_a/all.scss"), "$c: red;")
    File.write(themes_root.join("theme_a/assets/javascripts/theme_a/all.js"), "//= require_tree .")
    File.write(themes_root.join("theme_a/assets/stylesheets/theme_a/_mixins.scss"), "$x: 1;")
    File.write(themes_root.join("theme_a/assets/images/theme_a/photo.jpg"), "binary")
  end

  after do
    FileUtils.remove_entry(themes_root)
  end

  describe ".asset_paths" do
    it "includes stylesheets, javascripts and images directories" do
      paths = described_class.asset_paths(themes: ["theme_a"], themes_path: themes_root)

      expect(paths).to include(themes_root.join("theme_a/assets/stylesheets").to_s)
      expect(paths).to include(themes_root.join("theme_a/assets/javascripts").to_s)
      expect(paths).to include(themes_root.join("theme_a/assets/images").to_s)
      expect(paths).not_to include(themes_root.join("theme_a/assets/stylesheets/theme_a").to_s)
    end
  end

  describe ".precompile_list" do
    it "includes logical entrypoints and extras, not source files" do
      list = described_class.precompile_list(
        themes: ["theme_a"],
        themes_path: themes_root,
        extra_entrypoints: ["theme_a/shop.js"],
        mode: :entrypoints
      )

      expect(list).to include("theme_a/all.css", "theme_a/all.js", "theme_a/shop.js")
      expect(list).not_to include("all.css", "all.js")
      expect(list.none? { |entry| entry.to_s.end_with?(".scss") }).to be true
      expect(list.none? { |entry| entry.to_s.end_with?(".jpg") }).to be true
      expect(list.none? { |entry| entry.to_s.start_with?("/") || entry.to_s.include?("app/themes") }).to be true
    end

    it "returns an empty list when precompile_mode is :none" do
      list = described_class.precompile_list(
        themes: ["theme_a"],
        themes_path: themes_root,
        extra_entrypoints: ["theme_a/shop.js"],
        mode: :none
      )

      expect(list).to eq([])
    end

    it "maps all.scss to the logical all.css path" do
      expect(described_class.entrypoint_exist?("theme_a", "css", themes_path: themes_root)).to be true
      expect(described_class.precompile_list(themes: ["theme_a"], themes_path: themes_root, extra_entrypoints: [], mode: :entrypoints)).to include("theme_a/all.css")
    end
  end
end
