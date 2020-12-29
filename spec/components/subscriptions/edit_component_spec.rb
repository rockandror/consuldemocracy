require "rails_helper"

describe Subscriptions::EditComponent do
  let(:user) { create(:user, subscriptions_token: SecureRandom.base58(32)) }
  let(:component) { Subscriptions::EditComponent.new(user) }

  it "Render content" do
    render_inline component

    expect(page).to have_content "Notifications"
    expect(page).to have_content "Notify me by email when someone comments on my proposals or debates"
    expect(page).to have_content "Notify me by email when someone replies to my comments"
    expect(page).to have_content "Receive by email website relevant information"
    expect(page).to have_content "Receive a summary of proposal notifications"
    expect(page).to have_content "Receive emails about direct messages"
  end
end
