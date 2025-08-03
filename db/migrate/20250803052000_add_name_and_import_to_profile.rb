class AddNameAndImportToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :first_name, :string
    add_column :profiles, :last_name, :string
    add_column :profiles, :sixty_forty_import, :boolean, default: false
  end
end
