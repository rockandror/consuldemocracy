class AddCommentsCountToProbeOptions < ActiveRecord::Migration[4.2]
  def change
    add_column :probe_options, :comments_count, :integer, default: 0, null: false
  end
end
