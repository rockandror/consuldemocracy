namespace :geozones do
  desc "Create geozones for Cabildo de Tenerife"
  task load: :environment do
    load Rails.root.join("db", "geozones.rb")
  end
end
