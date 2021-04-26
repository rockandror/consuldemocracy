class AddTranslationSuresActions < ActiveRecord::Migration[5.0]
  def self.up
    [
      :proposal_title, :proposal_objective, :territorial_scope, :location_performance,
      :technical_visibility, :actions_taken
    ].each {|s| remove_column :sures_actuations, s }
    
    rename_column :sures_actuations, :cechk_multianno, :check_multianno
    Sures::Actuation.create_translation_table!(
      {
        proposal_title:       :string,
        proposal_objective:       :text,
        territorial_scope: :text,
        location_performance:   :text,
        technical_visibility:   :text,
        actions_taken: :text
      },
      { migrate_data: true }
    )
  end

  def self.down
    Sures::Actuation.drop_translation_table!
  end
end
