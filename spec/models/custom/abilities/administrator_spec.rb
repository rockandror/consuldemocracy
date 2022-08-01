require "rails_helper"
require "cancan/matchers"

describe Abilities::Administrator do
  subject(:ability) { Ability.new(user) }

  let(:user) { administrator.user }
  let(:administrator) { create(:administrator) }

  it { should_not be_able_to(:create, ::Administrator) }
  it { should_not be_able_to(:create, ::Manager) }
  it { should_not be_able_to(:create, ::Moderator) }
  it { should_not be_able_to(:create, ::Valuator) }
end

