class AddNewsletterTokenUsedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :newsletter_token_used_at, :datetime
  end
end
