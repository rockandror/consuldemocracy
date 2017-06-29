namespace :db do
  desc "Resets the database and loads it from db/dev_seeds.rb"
  task :dev_seed, [:print_log] => [:environment] do |t, args|
    @avoid_log = args[:print_log] == "avoid_log"
    load(Rails.root.join("db", "dev_seeds.rb"))
  end

  desc "Resets the database and loads it from db/pro_seeds.rb"
  task pro_seed: :environment do
    load(Rails.root.join("db", "pro_seeds.rb"))
  end
end
