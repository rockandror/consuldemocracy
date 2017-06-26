class AddInterestsCountToProposals < ActiveRecord::Migration
  def change
    add_column :proposals, :interests_count, :integer, default: 0
  end
end
