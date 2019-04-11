namespace :spending_proposals do

  desc "Migrates Existing 2016 Spending Proposals to Budget Investments (PARTIALLY)"
  task migrate_to_budgets: :environment do
    puts "We have #{SpendingProposal.count} spending proposals"
    puts "Migrating!!..."
    SpendingProposal.find_each { |sp| MigrateSpendingProposalsToInvestments.new.import(sp) }
    puts "And now we've got #{Budget.where(name: '2016').first.investments.count} budgets"
  end

  desc "Migrates winner Spending Proposals to their existing Budget Investments"
  task migrate_winner_spending_proposals: :environment do
    delegated_ballots = Forum.delegated_ballots
    winner_spending_proposals = []

    [nil, Geozone.all].flatten.each do |geozone|

      available_budget = Ballot.initial_budget(geozone).to_i
      spending_proposals = SpendingProposal.feasible.compatible.valuation_finished
                                           .by_geozone(geozone.try(:id))
      spending_proposals = SpendingProposal.sort_by_delegated_ballots_and_price(spending_proposals,
                                                                               delegated_ballots)

      spending_proposals.each do |spending_proposal|
        initial_budget = available_budget
        budget = available_budget - spending_proposal.price
        available_budget = budget if budget >= 0

        winner_spending_proposals << spending_proposal.id if budget >= 0

      end
    end

    Budget::Investment.where(original_spending_proposal_id: winner_spending_proposals)
                      .update_all(winner: true, selected: true)
  end

  desc "Migrates all necessary data from spending proposals to budget investments"
  task migrate: [
    "spending_proposals:pre_migrate",
    "spending_proposals:migrate_attributes",
    "spending_proposals:migrate_votes",
    "spending_proposals:migrate_ballots",
    "spending_proposals:migrate_delegated_ballots",
    "spending_proposals:post_migrate",
  ]

  desc "Run the required actions before the migration"
  task pre_migrate: :environment do
    require "migrations/spending_proposal/budget"

    puts "Starting pre rake tasks"
    Migrations::SpendingProposal::Budget.new.pre_rake_tasks
    puts "Finished"
  end

  desc "Migrates spending proposals attributes to budget investments attributes"
  task migrate_attributes: :environment do
    require "migrations/spending_proposal/budget_investments"

    puts "Starting to migrate attributes"
    Migrations::SpendingProposal::BudgetInvestments.new.update_all
    puts "Finished"
  end

  desc "Migrates spending proposl votes to budget investment votes"
  task migrate_votes: :environment do
    require "migrations/spending_proposal/vote"

    puts "Starting to migrate votes"
    Migrations::SpendingProposal::Vote.new.create_budget_investment_votes
    puts "Finished"
  end

  desc "Migrates spending proposals ballots to budget investments ballots"
  task migrate_ballots: :environment do
    require "migrations/spending_proposal/ballots"

    puts "Starting to migrate ballots"
    Migrations::SpendingProposal::Ballots.new.migrate_all
    puts "Finished"
  end

  desc "Migrates spending proposals delegated ballots to budget investments ballots"
  task migrate_delegated_ballots: :environment do
    require "migrations/spending_proposal/delegated_ballots"

    puts "Starting to migrate delegated ballots"
    Migrations::SpendingProposal::DelegatedBallots.new.migrate_all
    puts "Finished"
  end

  desc "Run the required actions after the migration"
  task post_migrate: :environment do
    require "migrations/spending_proposal/budget"

    puts "Starting post rake tasks"
    Migrations::SpendingProposal::Budget.new.post_rake_tasks
    puts "Finished"
  end

  desc "Destoy all associated spending proposal records"
  task :destroy_associated do
    puts "Starting to destroy associated records"
    Migrations::SpendingProposal::Investments.new.destroy_associated
    puts "Finished"
  end

end
