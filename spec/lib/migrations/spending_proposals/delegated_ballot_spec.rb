require "rails_helper"
require "migrations/spending_proposal/delegated_ballot"

describe Migrations::SpendingProposal::DelegatedBallot do

  let!(:budget) { create(:budget, slug: "2016") }

  describe "#initialize" do

    it "initializes a delegated spending proposal ballot" do
      forum = create(:forum)
      delegated_ballot = create(:ballot, user: forum.user)

      migration = Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot)

      expect(migration.delegated_ballot.class).to eq(Ballot)
      expect(migration.delegated_ballot.user).to eq(forum.user)
    end

  end

  describe "#migrate_delegated_ballot" do

    context "ballot" do

      it "migrates a delegated ballot for a single represented user" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)
        represented_user = create(:represented_user, representative: forum)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot.count).to eq(1)

        budget_ballot = Budget::Ballot.first
        expect(budget_ballot.user).to eq(represented_user)
      end

      it "migrates a delegated ballot for each represented user" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)

        represented_user1 = create(:represented_user, representative: forum)
        represented_user2 = create(:represented_user, representative: forum)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot.count).to eq(2)

        budget_ballot_users = Budget::Ballot.all.map(&:user)
        expect(budget_ballot_users).to include(represented_user1)
        expect(budget_ballot_users).to include(represented_user2)
      end

      it "only creates delegated ballots if there are represented users" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot.count).to eq(0)
      end

      it "verifies if represented user also created a ballot" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)

        represented_user = create(:represented_user, representative: forum)
        represented_user_ballot = create(:budget_ballot, user: represented_user, budget: budget)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot.count).to eq(1)

        budget_ballot = Budget::Ballot.first
        expect(budget_ballot.user).to eq(represented_user)
      end

      it "verifies if delegated ballot has already been migrated" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)
        represented_user = create(:represented_user, representative: forum)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot
        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot.count).to eq(1)

        budget_ballot = Budget::Ballot.first
        expect(budget_ballot.user).to eq(represented_user)
      end

    end

    context "ballot lines" do

      let!(:group)   { create(:budget_group, budget: budget) }
      let!(:heading) { create(:budget_heading, group: group) }

      it "migrates a single delegated ballot line" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)
        represented_user = create(:represented_user, representative: forum)

        spending_proposal = create(:spending_proposal, feasible: true)
        delegated_ballot.spending_proposals << spending_proposal

        budget_investment = budget_invesment_for(spending_proposal, heading: heading)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        budget_investment_ballot = Budget::Ballot.first
        expect(budget_investment_ballot.investments).to eq([budget_investment])
      end

      it "migrates all delegated ballot lines for a ballot" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)
        represented_user = create(:represented_user, representative: forum)

        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)
        spending_proposal3 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)
        budget_investment3 = budget_invesment_for(spending_proposal3, heading: heading)

        delegated_ballot.spending_proposals << spending_proposal1
        delegated_ballot.spending_proposals << spending_proposal2

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        budget_investment_ballot = Budget::Ballot.first

        expect(budget_investment_ballot.investments).to include(budget_investment1)
        expect(budget_investment_ballot.investments).to include(budget_investment2)
        expect(budget_investment_ballot.investments).not_to include(budget_investment3)
      end

      it "migrates all delegated ballot lines for each represented user" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)

        represented_user1 = create(:represented_user, representative: forum)
        represented_user2 = create(:represented_user, representative: forum)

        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)
        spending_proposal3 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)
        budget_investment3 = budget_invesment_for(spending_proposal3, heading: heading)

        delegated_ballot.spending_proposals << spending_proposal1
        delegated_ballot.spending_proposals << spending_proposal2

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        represented_user1_ballot = Budget::Ballot.where(user: represented_user1).first
        expect(represented_user1_ballot.investments).to include(budget_investment1)
        expect(represented_user1_ballot.investments).to include(budget_investment2)
        expect(represented_user1_ballot.investments).not_to include(budget_investment3)

        represented_user2_ballot = Budget::Ballot.where(user: represented_user2).first
        expect(represented_user2_ballot.investments).to include(budget_investment1)
        expect(represented_user2_ballot.investments).to include(budget_investment2)
        expect(represented_user2_ballot.investments).not_to include(budget_investment3)
      end

      it "migrates ballot lines if represented user had a ballot with no ballot lines" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)

        represented_user = create(:represented_user, representative: forum)
        represented_user_ballot = create(:budget_ballot, user: represented_user, budget: budget)

        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)
        spending_proposal3 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)
        budget_investment3 = budget_invesment_for(spending_proposal3, heading: heading)

        delegated_ballot.spending_proposals << spending_proposal1
        delegated_ballot.spending_proposals << spending_proposal2

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(represented_user_ballot.investments).to include(budget_investment1)
        expect(represented_user_ballot.investments).to include(budget_investment2)
        expect(represented_user_ballot.investments).not_to include(budget_investment3)
      end

      it "verifies if represented user already has ballot lines" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)

        represented_user = create(:represented_user, representative: forum)
        represented_user_ballot = create(:budget_ballot, user: represented_user, budget: budget)

        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)

        represented_user_ballot.investments << budget_investment1
        delegated_ballot.spending_proposals << spending_proposal2

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot.count).to eq(1)

        budget_investment_ballot = Budget::Ballot.first
        expect(represented_user_ballot.user).to eq(represented_user)

        expect(represented_user_ballot.investments).to include(budget_investment1)
        expect(represented_user_ballot.investments).not_to include(budget_investment2)
      end

      it "verifies if delegated ballot lines have already been migrated" do
        forum = create(:forum)
        delegated_ballot = create(:ballot, user: forum.user)
        represented_user = create(:represented_user, representative: forum)

        spending_proposal = create(:spending_proposal, feasible: true)
        delegated_ballot.spending_proposals << spending_proposal

        budget_investment = budget_invesment_for(spending_proposal, heading: heading)

        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot
        Migrations::SpendingProposal::DelegatedBallot.new(delegated_ballot).migrate_delegated_ballot

        expect(Budget::Ballot::Line.count).to eq(1)
        expect(Budget::Ballot::Line.first.investment).to eq(budget_investment)
      end

    end
  end
end
