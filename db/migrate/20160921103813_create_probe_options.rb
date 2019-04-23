class CreateProbeOptions < ActiveRecord::Migration[4.2]
  def change
    create_table :probe_options do |t|
      t.string :code
      t.string :name
      t.belongs_to :probe
      t.integer :cached_votes_up, default: 0
    end

    add_index  :probe_options, :cached_votes_up
  end
end
