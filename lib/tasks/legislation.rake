namespace :legislation do

  desc "Copy old debate comments to correspondig new questions"
  task debate_comments_to_questions: :environment do
    require "migrations/legislation_comments_migration"
    LegislationCommentsMigration.new.migrate_data
  end
end
