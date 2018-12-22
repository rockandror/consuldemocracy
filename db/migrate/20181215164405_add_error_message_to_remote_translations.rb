class AddErrorMessageToRemoteTranslations < ActiveRecord::Migration
  def change
    add_column :remote_translations, :error_message, :text
  end
end
