class AddSelectionsCounterCacheToProbeOption < ActiveRecord::Migration[4.2]
  def change
    add_column :probe_options, :probe_selections_count, :integer, default: 0
  end
end
