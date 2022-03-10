require "rails_helper"

describe Layout::NotificationItemComponent do
  describe "#render?" do
    it "renders for devise users" do
      render_inline Layout::NotificationItemComponent.new(create(:user))

      expect(page).to have_css "li#notifications"
    end

    it "does not render for guest users" do
      render_inline Layout::NotificationItemComponent.new(create(:guest))

      expect(page).not_to be_rendered
    end
  end
end
