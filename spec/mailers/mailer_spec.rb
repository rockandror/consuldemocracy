require "rails_helper"

describe Mailer do
  describe "#comment" do
    it "sends emails in the user's locale" do
      user = create(:user, locale: "es")
      proposal = create(:proposal, author: user)
      comment = create(:comment, commentable: proposal)

      email = I18n.with_locale :en do
        Mailer.comment(comment)
      end

      expect(email.subject).to include("comentado")
    end

    it "reads the from address at runtime" do
      Setting["mailer_from_name"] = "New organization"
      Setting["mailer_from_address"] = "new@consul.dev"

      email = Mailer.comment(create(:comment))

      expect(email).to deliver_from "New organization <new@consul.dev>"
    end
  end

  describe "moderation voting proposal" do
    let(:author) { create(:user) }
    let(:proposal) { create(:proposal, author: author, title: "New proposal title") }

    before do
      ActionMailer::Base.deliveries.clear
    end

    it "#voting_review" do
      Mailer.voting_review(proposal).deliver_now

      email = open_last_email

      expect(email).to deliver_to(author)
      expect(email).to have_subject("Thank you for creating a proposal!")
      expect(email).to have_body_text("We would like to inform you that your proposal is pending review")
      expect(email).to have_body_text("New proposal title")
    end
  end
end
