require 'spec_helper'

describe ThemesOnRails::Engine do
  context 'assets.paths' do
    it 'includes `theme_a`: images, javascripts, stylesheets' do
      expect(Rails.application.config.assets.paths.to_s).to match(/theme_a\/assets\/images/)
      expect(Rails.application.config.assets.paths.to_s).to match(/theme_a\/assets\/javascripts/)
      expect(Rails.application.config.assets.paths.to_s).to match(/theme_a\/assets\/stylesheets/)
    end

    it 'includes `theme_b`: images, javascripts, stylesheets' do
      expect(Rails.application.config.assets.paths.to_s).to match(/theme_b\/assets\/images/)
      expect(Rails.application.config.assets.paths.to_s).to match(/theme_b\/assets\/javascripts/)
      expect(Rails.application.config.assets.paths.to_s).to match(/theme_b\/assets\/stylesheets/)
    end
  end

  context 'i18n.load_path' do
    it 'includes `theme_c`: locales' do
      expect(Rails.application.config.i18n.load_path.to_s).to match(/theme_c\/locales\/en.yml/)
      expect(Rails.application.config.i18n.load_path.to_s).to match(/theme_c\/locales\/km.yml/)
    end
  end

  context 'assets.precompile' do
    let(:precompile_strings) do
      Rails.application.config.assets.precompile.select { |entry| entry.is_a?(String) }
    end

    it 'includes logical entrypoints' do
      expect(precompile_strings).to include("theme_a/all.css")
      expect(precompile_strings).to include("theme_a/all.js")
    end

    it 'does not include unprefixed all.css or all.js' do
      expect(precompile_strings).not_to include("all.css")
      expect(precompile_strings).not_to include("all.js")
    end

    it 'does not include absolute theme paths, scss sources or images' do
      expect(precompile_strings.none? { |entry| entry.start_with?("/") && entry.include?("/app/themes/") }).to be true
      expect(precompile_strings.none? { |entry| entry.end_with?(".scss") }).to be true
      expect(precompile_strings.none? { |entry| entry.end_with?(".jpg") }).to be true
    end
  end
end