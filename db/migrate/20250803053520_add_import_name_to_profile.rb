class AddImportNameToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :import_name, :string
    add_column :profiles, :imported_at, :datetime
  end
end
