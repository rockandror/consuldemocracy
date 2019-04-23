class AddDebateToProbeOptions < ActiveRecord::Migration[4.2]
  def change
    add_reference :probe_options, :debate, index: true, foreign_key: true
  end
end
