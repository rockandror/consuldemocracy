class AddNewsletterTokenToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :newsletter_token, :string
  end
end
