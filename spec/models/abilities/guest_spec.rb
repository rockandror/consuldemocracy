require "rails_helper"
require "cancan/matchers"

describe Abilities::Guest do
  subject(:ability) { Abilities::Guest.new(user) }

  let(:user) { create(:guest) }
  let(:poll) { create(:poll) }
  let(:poll_question) { create(:poll_question, poll: poll) }

  it { should be_able_to(:answer, Poll) }
  it { should be_able_to(:answer, Poll::Question) }
end
