class AddComunityHideProposals < ActiveRecord::Migration[5.0]
  def change
    add_column :proposals, :comunity_hide, :boolean, :default => false
  end
end
