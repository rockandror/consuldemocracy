class ChangeReferencesJoinTable < ActiveRecord::Migration[5.0]
  def change
    remove_reference :legislation_cat_prop, :proposal

    add_reference :legislation_cat_prop, :legislation_proposal, foreign_key: true, as: :proposal
  end
end
