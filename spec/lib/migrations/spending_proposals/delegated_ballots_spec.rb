require "rails_helper"
require "migrations/spending_proposal/delegated_ballots"

describe Migrations::SpendingProposal::DelegatedBallots do

  let!(:budget) { create(:budget, slug: "2016") }

  describe "#initialize" do

    it "initializes all delegated spending proposal ballots" do
      forum1 = create(:forum)
      delegated_ballot1 = create(:ballot, user: forum1.user)

      forum2 = create(:forum)
      delegated_ballot2 = create(:ballot, user: forum2.user)

      non_delegated_ballot = create(:ballot)

      migration = Migrations::SpendingProposal::DelegatedBallots.new

      expect(migration.delegated_ballots.count).to eq(2)
      expect(migration.delegated_ballots).to include(delegated_ballot1)
      expect(migration.delegated_ballots).to include(delegated_ballot2)
      expect(migration.delegated_ballots).not_to include(non_delegated_ballot)
    end

  end

  describe "#migrate_all" do

    context "ballot" do

      it "migrates all delegated spending proposal ballots to budget investment ballots" do
        forum1 = create(:forum)
        represented_user1 = create(:represented_user, representative: forum1)
        delegated_ballot1 = create(:ballot, user: forum1.user)

        forum2 = create(:forum)
        represented_user2 = create(:represented_user, representative: forum2)
        delegated_ballot2 = create(:ballot, user: forum2.user)

        Migrations::SpendingProposal::DelegatedBallots.new.migrate_all

        expect(Budget::Ballot.count).to eq(2)

        budget_ballot_users = Budget::Ballot.all.map(&:user)
        expect(budget_ballot_users).to include(represented_user1)
        expect(budget_ballot_users).to include(represented_user2)
      end

    end

    context "ballot line" do

      let!(:group)   { create(:budget_group, budget: budget) }
      let!(:heading) { create(:budget_heading, group: group) }

      it "migrates all delegated spending proposal ballot lines to budget investment ballot lines" do
        forum1 = create(:forum)
        represented_user1 = create(:represented_user, representative: forum1)
        delegated_ballot1 = create(:ballot, user: forum1.user)

        forum2 = create(:forum)
        represented_user2 = create(:represented_user, representative: forum2)
        delegated_ballot2 = create(:ballot, user: forum2.user)

        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)
        spending_proposal3 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)
        budget_investment3 = budget_invesment_for(spending_proposal3, heading: heading)

        delegated_ballot1.spending_proposals << spending_proposal1
        delegated_ballot1.spending_proposals << spending_proposal2

        delegated_ballot2.spending_proposals << spending_proposal1

        Migrations::SpendingProposal::DelegatedBallots.new.migrate_all

        represented_user_ballot1 = Budget::Ballot.where(user: represented_user1).first

        expect(represented_user_ballot1.investments).to include(budget_investment1)
        expect(represented_user_ballot1.investments).to include(budget_investment2)
        expect(represented_user_ballot1.investments).not_to include(budget_investment3)

        represented_user_ballot2 = Budget::Ballot.where(user: represented_user2).first

        expect(represented_user_ballot2.investments).to include(budget_investment1)
        expect(represented_user_ballot2.investments).not_to include(budget_investment2)
        expect(represented_user_ballot2.investments).not_to include(budget_investment3)
      end

    end
  end
end
