class AddAttachmentDataToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :attachment_data, :text
  end
end
