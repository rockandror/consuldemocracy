# require 'spec/rails_helper.rb'

shared_examples_for "hidden translations" do |factory_name|
  let(:migrations_paths) { Rails.root.join("db/migrate") }
  let(:previous_version) { 20181206153510 }

  before do
   ActiveRecord::Migrator.migrate(migrations_paths, previous_version)
  end

  after do
    # Return to latest state
    ActiveRecord::Migrator.migrate(migrations_paths)
  end

  it "Should not raise an exception when hidden_at column does not exist yet
     on related translation class" do
    expect{ create(factory_name) }
      .not_to raise_exception { ActiveRecord::UnknownAttributeError }
  end
end
