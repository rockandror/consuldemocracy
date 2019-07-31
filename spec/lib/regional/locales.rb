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

  describe "Available Locales" do

    context "#load_i18n_available_locales" do

      let!(:available_locales) { I18n.available_locales }
      let!(:available_locales_without_de) { I18n.available_locales - [:de] }

      it "when related Setting with available_locales are blank, return available_locales defined in application.rb" do
        Setting.where("key LIKE ?", "regional.available_locale.%").delete_all

        Regional::Locales.load_i18n_available_locales

        expect(I18n.available_locales).to eq available_locales
      end

      it "when related Setting with default_locale is filled, return default_locale defined in Settings" do
        Setting["regional.available_locale.de"] = nil

        Regional::Locales.load_i18n_available_locales

        expect(I18n.available_locales).to eq available_locales_without_de
      end

    end

  end

end
