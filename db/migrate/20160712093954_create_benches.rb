class CreateBenches < ActiveRecord::Migration[4.2]
  def change
    create_table :benches do |t|
      t.string :name
      t.string :code
    end
  end
end
