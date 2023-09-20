require "rails_helper"

describe Shared::InFavorAgainstComponent do
  let(:debate) { create(:debate) }
  let(:component) { Shared::InFavorAgainstComponent.new(debate) }

  describe "Agree and disagree buttons" do
    it "can create a vote when the user has not yet voted" do
      sign_in(create(:user))

      render_inline component

      page.find(".in-favor") do |in_favor_block|
        expect(in_favor_block).to have_css "form[action*='votes'][method='post']"
        expect(in_favor_block).not_to have_css "input[name='_method']", visible: :hidden
      end

      page.find(".against") do |against_block|
        expect(against_block).to have_css "form[action*='votes'][method='post']"
        expect(against_block).not_to have_css "input[name='_method']", visible: :hidden
      end
    end
  end
end
