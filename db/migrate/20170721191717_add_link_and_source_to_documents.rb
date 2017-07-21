class AddLinkAndSourceToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :link, :string
    add_column :documents, :source, :integer, default: 0
  end
end
