class AddFilmLibraryToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :film_library, :boolean, default: false
  end
end
