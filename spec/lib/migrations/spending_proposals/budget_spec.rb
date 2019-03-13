require "rails_helper"
require "migrations/spending_proposal/budget"

describe Migrations::SpendingProposal::Budget do

  let!(:budget) { create(:budget, slug: "2016") }

  describe "#initialize" do

    it "initializes the budget to be migrated" do
      migration = Migrations::SpendingProposal::Budget.new

      expect(migration.budget).to eq(budget)
    end

  end

  describe "#pre_rake_tasks" do

    let!(:city_group)   { create(:budget_group, budget: budget) }
    let!(:city_heading) { create(:budget_heading, group: city_group, name: "Toda la ciudad") }

    let!(:district_group)    { create(:budget_group, budget: budget) }
    let!(:district_heading1) { create(:budget_heading, group: district_group, name: "Arganzuela") }
    let!(:district_heading2) { create(:budget_heading, group: district_group, name: "Barajas") }

    context "heading price" do

      it "updates the city heading's price" do
        migration = Migrations::SpendingProposal::Budget.new
        migration.pre_rake_tasks

        city_heading.reload
        expect(city_heading.price).to eq(24000000)
      end

      it "updates the district headings' price" do
        migration = Migrations::SpendingProposal::Budget.new
        migration.pre_rake_tasks

        district_heading1.reload
        district_heading2.reload
        expect(district_heading1.price).to eq(1556169)
        expect(district_heading2.price).to eq(433589)
      end
    end

    context "heading population" do

      it "updates the city heading's population" do
        migration = Migrations::SpendingProposal::Budget.new
        migration.pre_rake_tasks

        city_heading.reload
        expect(city_heading.population).to eq(2706401)
      end

      it "updates the district headings' population" do
        migration = Migrations::SpendingProposal::Budget.new
        migration.pre_rake_tasks

        district_heading1.reload
        district_heading2.reload
        expect(district_heading1.population).to eq(131429)
        expect(district_heading2.population).to eq(37725)
      end

    end

    context "selected investments" do

      let!(:spending_proposal1) { create(:spending_proposal, feasible: true, valuation_finished: true) }
      let!(:spending_proposal2) { create(:spending_proposal, feasible: true, valuation_finished: true) }
      let!(:spending_proposal3) { create(:spending_proposal, feasible: true, valuation_finished: false) }
      let!(:spending_proposal4) { create(:spending_proposal, feasible: false, valuation_finished: true) }

      let!(:budget_investment1) { create(:budget_investment, budget: budget, original_spending_proposal_id: spending_proposal1.id) }
      let!(:budget_investment2) { create(:budget_investment, budget: budget, original_spending_proposal_id: spending_proposal2.id) }
      let!(:budget_investment3) { create(:budget_investment, budget: budget, original_spending_proposal_id: spending_proposal3.id) }
      let!(:budget_investment4) { create(:budget_investment, budget: budget, original_spending_proposal_id: spending_proposal4.id) }

      it "marks feasible and valuation finished investments as selected" do
        migration = Migrations::SpendingProposal::Budget.new
        migration.pre_rake_tasks

        budget_investment1.reload
        budget_investment2.reload
        budget_investment3.reload
        budget_investment4.reload

        expect(budget_investment1.selected).to eq(true)
        expect(budget_investment2.selected).to eq(true)
        expect(budget_investment3.selected).to eq(false)
        expect(budget_investment4.selected).to eq(false)
      end

    end
  end

  describe "#post_rake_tasks" do

    let!(:group)   { create(:budget_group, budget: budget) }
    let!(:heading) { create(:budget_heading, group: group, price: 99999999) }

    it "Destros all forum votes" do
      forum1 = create(:forum)
      forum2 = create(:forum)
      investment = create(:budget_investment, heading: heading)

      forum1_vote = create(:vote, voter: forum1.user, votable: investment)
      forum2_vote = create(:vote, voter: forum2.user, votable: investment)
      user_vote = create(:vote, votable: investment)

      migration = Migrations::SpendingProposal::Budget.new
      migration.post_rake_tasks

      expect(Vote.count).to eq(1)
      expect(Vote.all).to include(user_vote)
    end

    it "Destros all forum ballots" do
      forum1 = create(:forum)
      forum2 = create(:forum)
      investment = create(:budget_investment, :selected, heading: heading)

      forum1_ballot = create(:budget_ballot, budget: budget, user: forum1.user)
      forum2_ballot = create(:budget_ballot, budget: budget, user: forum2.user)
      user_ballot   = create(:budget_ballot, budget: budget)

      create(:budget_ballot_line, ballot: forum1_ballot, investment: investment)
      create(:budget_ballot_line, ballot: forum2_ballot, investment: investment)
      create(:budget_ballot_line, ballot: user_ballot,   investment: investment)

      migration = Migrations::SpendingProposal::Budget.new
      migration.post_rake_tasks

      expect(Budget::Ballot.count).to eq(1)
      expect(Budget::Ballot.all).to include(user_ballot)

      expect(Budget::Ballot::Line.count).to eq(1)
      expect(Budget::Ballot::Line.all).to include(user_ballot.lines.first)
    end

    it "Updates cached votes" do
      investment = create(:budget_investment, :selected, heading: heading)

      create(:vote, votable: investment)
      create(:vote, votable: investment)

      investment.update(cached_votes_up: 3)

      investment.reload
      expect(investment.cached_votes_up).to eq(3)

      migration = Migrations::SpendingProposal::Budget.new
      migration.post_rake_tasks

      investment.reload
      expect(investment.cached_votes_up).to eq(2)
    end

    it "Updates cached ballot lines" do
      investment = create(:budget_investment, :selected, heading: heading)

      ballot1 = create(:budget_ballot, budget: budget)
      ballot2 = create(:budget_ballot, budget: budget)

      create(:budget_ballot_line, ballot: ballot1, investment: investment)
      create(:budget_ballot_line, ballot: ballot2, investment: investment)

      investment.update(ballot_lines_count: 3)

      investment.reload
      expect(investment.ballot_lines_count).to eq(3)

      migration = Migrations::SpendingProposal::Budget.new
      migration.post_rake_tasks

      investment.reload
      expect(investment.ballot_lines_count).to eq(2)
    end

    it "Calculates winners" do
      ballot = create(:budget_ballot, budget: budget)

      investment1 = create(:budget_investment, :selected, heading: heading)
      investment2 = create(:budget_investment, :selected, heading: heading)
      investment3 = create(:budget_investment, :selected, heading: heading)

      create(:budget_ballot_line, ballot: ballot, investment: investment1)
      create(:budget_ballot_line, ballot: ballot, investment: investment2)

      results = Budget::Result.new(budget, heading)
      expect(results.winners.count).to eq(0)

      migration = Migrations::SpendingProposal::Budget.new
      migration.post_rake_tasks

      expect(results.winners.count).to eq(3)
    end

  end
end
