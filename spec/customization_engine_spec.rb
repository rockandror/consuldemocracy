require "rails_helper"

# This module tests functionality related with custom application files
# TODO test models, controllers, etc...

describe "Check Custom Locales" do
  let!(:default_path) { I18n.load_path }

  after do
    reset_load_path_and_reload(default_path)
  end

  describe "Customization Engine" do
    let(:test_key)      { I18n.t("account.show.change_credentials_link") }

    before do
      reset_load_path_and_reload(default_path)
    end

    it "loads custom and override original locales" do
      increase_load_path_and_reload(Dir[Rails.root.join("spec", "support",
                                                        "locales", "custom", "*.{rb,yml}")])
      expect(test_key).to eq "Overriden string with custom locales"
    end

    it "does not override original locales" do
      increase_load_path_and_reload(Dir[Rails.root.join("spec", "support",
                                                        "locales", "*.{rb,yml}")])
      expect(test_key).to eq "Not overriden string with custom locales"
    end

    def increase_load_path_and_reload(path)
      I18n.load_path += path
      I18n.reload!
    end
  end

  describe "I18n config load_path" do

    let(:test_key)      { I18n.t("management.document_verifications.not_in_census") }

    it "loads custom and override original locales" do
      i18n_load_path_correctly

      expect(test_key).to eq "This document is not registered in Madrid Census."
    end

    it "load original locales" do
      i18n_load_path_wrongly

      expect(test_key).to eq "This document is not registered in Madrid."
    end

    def i18n_load_path_correctly
      I18n.load_path = Dir[Rails.root.join("config", "locales", "**[^custom]*", "*.{rb,yml}")]
      I18n.load_path += Dir[Rails.root.join("config", "locales", "custom", "**", "*.{rb,yml}")]

      I18n.reload!
    end

    def i18n_load_path_wrongly
      I18n.load_path = Dir[Rails.root.join("config", "locales", "custom", "**", "*.{rb,yml}")]
      I18n.load_path += Dir[Rails.root.join("config", "locales", "**[^custom]*", "*.{rb,yml}")]

      I18n.reload!
    end

  end

  def reset_load_path_and_reload(path)
    I18n.load_path = path
    I18n.reload!
  end

end
