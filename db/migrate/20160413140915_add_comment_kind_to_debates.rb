class AddCommentKindToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :comment_kind, :string, default: 'comment'
  end
end
