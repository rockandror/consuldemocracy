class RemoveCachedVotesUpFromProbeOptions < ActiveRecord::Migration[4.2]
  def change
    remove_column :probe_options, :cached_votes_up, :integer, default: 0
  end
end
