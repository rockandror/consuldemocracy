class AddFieldFilmLibrary < ActiveRecord::Migration[5.0]
  def change
    add_column :legislation_processes, :film_library_limit, :integer
    add_column :legislation_processes, :film_library_admin, :boolean, :default => false
  end
end
