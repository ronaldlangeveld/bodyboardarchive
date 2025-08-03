class AddImportLocationToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :import_location, :string, null: true, default: nil
    add_index :profiles, :import_location
  end
end
