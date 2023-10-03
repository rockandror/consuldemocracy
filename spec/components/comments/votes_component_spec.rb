require "rails_helper"

describe Comments::VotesComponent do
  let(:user) { create(:user) }
  let(:comment) { create(:comment, user: user) }
  let(:component) { Comments::VotesComponent.new(comment) }

  describe "aria-pressed attribute" do
    it "is true when the in-favor button is pressed" do
      comment.vote_by(voter: user, vote: "yes")
      sign_in(user)

      render_inline component

      page.find(".in-favor") do |in_favor_block|
        expect(in_favor_block).to have_css "button[aria-pressed='true']"
        expect(in_favor_block).to have_css "form[action*='votes'][method='post']"
        expect(in_favor_block).to have_css "input[name='_method'][value='delete']", visible: :hidden
      end

      page.find(".against") do |against_block|
        expect(against_block).to have_css "button[aria-pressed='false']"
        expect(against_block).to have_css "form[action*='votes'][method='post']"
        expect(against_block).not_to have_css "input[name='_method']", visible: :hidden
      end
    end

    it "is true when the against button is pressed" do
      comment.vote_by(voter: user, vote: "no")
      sign_in(user)

      render_inline component

      page.find(".in-favor") do |in_favor_block|
        expect(in_favor_block).to have_css "button[aria-pressed='false']"
        expect(in_favor_block).to have_css "form[action*='votes'][method='post']"
        expect(in_favor_block).not_to have_css "input[name='_method']", visible: :hidden
      end

      page.find(".against") do |against_block|
        expect(against_block).to have_css "button[aria-pressed='true']"
        expect(against_block).to have_css "form[action*='votes'][method='post']"
        expect(against_block).to have_css "input[name='_method'][value='delete']", visible: :hidden
      end
    end

    it "is false when neither the 'in-favor' button nor the 'against' button are pressed" do
      sign_in(user)

      render_inline component

      page.find(".in-favor") do |in_favor_block|
        expect(in_favor_block).to have_css "button[aria-pressed='false']"
        expect(in_favor_block).to have_css "form[action*='votes'][method='post']"
        expect(in_favor_block).not_to have_css "input[name='_method']", visible: :hidden
      end

      page.find(".against") do |against_block|
        expect(against_block).to have_css "button[aria-pressed='false']"
        expect(against_block).to have_css "form[action*='votes'][method='post']"
        expect(against_block).not_to have_css "input[name='_method']", visible: :hidden
      end
    end
  end
end
