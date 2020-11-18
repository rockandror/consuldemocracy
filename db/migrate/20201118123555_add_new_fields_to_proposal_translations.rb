class AddNewFieldsToProposalTranslations < ActiveRecord::Migration[5.1]
  def change
    add_column :proposal_translations, :details, :string
    add_column :proposal_translations, :request, :text
  end
end
