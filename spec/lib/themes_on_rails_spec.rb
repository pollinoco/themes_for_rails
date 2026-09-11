require "spec_helper"
require "tmpdir"
require "fileutils"

describe ThemesOnRails do
  describe ".all" do
    it "lists theme directories under Rails.root, not cwd" do
      Dir.mktmpdir do |cwd|
        FileUtils.mkdir_p(File.join(cwd, "app/themes/fake_from_cwd"))
        Dir.chdir(cwd) do
          ThemesOnRails.reset!
          expect(ThemesOnRails.all).to include("theme_a", "theme_b", "theme_c")
          expect(ThemesOnRails.all).not_to include("fake_from_cwd")
        end
      end
    end

    it "ignores hidden directories and returns a sorted list" do
      ThemesOnRails.reset!
      expect(ThemesOnRails.all).to eq(ThemesOnRails.all.sort)
      expect(ThemesOnRails.all.none? { |name| name.start_with?(".") }).to be true
    end
  end

  describe ".configure" do
    it "yields the configuration" do
      ThemesOnRails.reset!
      ThemesOnRails.configure do |c|
        c.precompile_mode = :none
        c.extra_entrypoints = %w[theme_a/shop.js]
      end

      expect(ThemesOnRails.config.precompile_mode).to eq(:none)
      expect(ThemesOnRails.config.extra_entrypoints).to eq(%w[theme_a/shop.js])
    end
  end
end
