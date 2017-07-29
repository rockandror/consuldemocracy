class RemoveAttachmentFromDocuments < ActiveRecord::Migration
  def change
    remove_attachment :documents, :attachment
  end
end
