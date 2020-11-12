class SubsectionWeb < ActiveRecord::Migration[5.0]
  def change
    add_column :banners, :subsection, :boolean, :default => false
    #Ex:- :default =>''
  end
end
