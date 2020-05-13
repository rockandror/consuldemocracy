class AddTopicToProbeOptions < ActiveRecord::Migration[5.0]
  def change
    add_reference :probe_options, :topic, index: true, foreign_key: true
  end
end
