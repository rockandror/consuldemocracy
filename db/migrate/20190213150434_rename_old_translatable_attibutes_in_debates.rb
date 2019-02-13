class RenameOldTranslatableAttibutesInDebates < ActiveRecord::Migration
  def change
    rename_column :debates, :title, :deprecated_title
    rename_column :debates, :description, :deprecated_description
  end
end
