require "rails_helper"

describe Regional::Locales do

  describe "Default Locale" do

    context "#load_i18n_default_locale" do

      after do
        I18n.default_locale = :en
      end

      it "when related Setting with default_locale is blank, return default_locale defined in application.rb" do
        Setting["regional.default_locale.key"] = nil

        Regional::Locales.load_i18n_default_locale

        expect(I18n.default_locale).to eq :en
      end

      it "when related Setting with default_locale is filled, return default_locale defined in Settings" do
        Setting["regional.default_locale.key"] = :es

        Regional::Locales.load_i18n_default_locale

        expect(I18n.default_locale).to eq :es
      end

    end

  end

end
