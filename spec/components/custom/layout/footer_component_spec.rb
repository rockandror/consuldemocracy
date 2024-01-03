require "rails_helper"

describe Layout::FooterComponent do
  describe "when the cookies consent feature is enabled" do
    before { Setting["feature.cookies_consent"] = true }

    it "shows a link to the cookies setup modal when the cookies setup page is enabled" do
      Setting["cookies_consent.setup_page"] = true

      render_inline Layout::FooterComponent.new

      page.find("footer") do |footer|
        expect(footer).to have_css "a[data-open=cookies_consent_setup]", text: "Cookies setup"
      end
    end

    it "does not show a link to the cookies setup modal when the cookies setup page is disabled" do
      Setting["cookies_consent.setup_page"] = false

      render_inline Layout::FooterComponent.new

      page.find("footer") do |footer|
        expect(footer).not_to have_css "a[data-open=cookies_consent_setup]", text: "Cookies setup"
      end
    end
  end
end
