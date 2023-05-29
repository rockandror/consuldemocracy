require "rails_helper"

describe Debates::VotesComponent do
  let(:debate) { create(:debate, title: "What about the 2030 agenda?") }
  let(:component) { Debates::VotesComponent.new(debate) }

  describe "Agree and disagree buttons" do
    it "is shown to anonymous users alongside a reminder to sign in" do
      render_inline component

      expect(page).to have_button "I agree"
      expect(page).to have_button "I disagree"
      expect(page).to have_content "You must sign in or sign up to continue."
    end

    it "is shown to identified users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_button count: 2
      expect(page).to have_button "I agree", title: "I agree"
      expect(page).to have_button "I agree with What about the 2030 agenda?"
      expect(page).to have_button "I disagree", title: "I disagree"
      expect(page).to have_button "I don't agree with What about the 2030 agenda?"
      expect(page).not_to have_content "You must sign in or sign up to continue."
    end

    it "does not include result percentages" do
      create(:vote, votable: debate)
      sign_in(create(:user))

      render_inline component

      expect(page).to have_button count: 2
      expect(page).to have_button "I agree"
      expect(page).to have_button "I disagree"
      expect(page).not_to have_button text: "%"
      expect(page).not_to have_button text: "100"
      expect(page).not_to have_button text: "0"
    end

    describe "aria-pressed attribute" do
      let(:user) { create(:user) }

      it "is true when the in-favor button is pressed" do
        debate.register_vote(user, "yes")
        sign_in(user)

        render_inline component

        page.find(".in-favor") do |in_favor_block|
          expect(in_favor_block).to have_css "button[aria-pressed='true']"
        end

        page.find(".against") do |against_block|
          expect(against_block).to have_css "button[aria-pressed='false']"
        end
      end

      it "is true when the against button is pressed" do
        debate.register_vote(user, "no")
        sign_in(user)

        render_inline component

        page.find(".in-favor") do |in_favor_block|
          expect(in_favor_block).to have_css "button[aria-pressed='false']"
        end

        page.find(".against") do |against_block|
          expect(against_block).to have_css "button[aria-pressed='true']"
        end
      end

      it "is false when neither the 'in-favor' button nor the 'against' button are pressed" do
        sign_in(user)

        render_inline component

        page.find(".in-favor") do |in_favor_block|
          expect(in_favor_block).to have_css "button[aria-pressed='false']"
        end

        page.find(".against") do |against_block|
          expect(against_block).to have_css "button[aria-pressed='false']"
        end
      end
    end
  end
end
