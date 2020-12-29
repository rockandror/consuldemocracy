require "rails_helper"

describe "Subscriptions" do
  let(:user) { create(:user, subscriptions_token: SecureRandom.base58(32)) }

  context "Update" do
    scenario "Allow update the status notification" do
      user.update!(email_on_comment: true,
                   email_on_comment_reply: true,
                   email_on_direct_message: true,
                   email_digest: true,
                   newsletter: true)
      visit edit_subscriptions_path(token: user.subscriptions_token)

      uncheck "Notify me by email when someone comments on my proposals or debates"
      uncheck "Notify me by email when someone replies to my comments"
      uncheck "Receive by email website relevant information"
      uncheck "Receive a summary of proposal notifications"
      uncheck "Receive emails about direct messages"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(user.reload.email_on_comment).to eq false
      expect(user.reload.email_on_comment_reply).to eq false
      expect(user.reload.email_on_direct_message).to eq false
      expect(user.reload.email_digest).to eq false
      expect(user.reload.newsletter).to eq false
    end
  end
end
