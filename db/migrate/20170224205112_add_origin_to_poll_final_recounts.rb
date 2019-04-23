class AddOriginToPollFinalRecounts < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_final_recounts, :origin, :string, default: "booth"
  end
end
