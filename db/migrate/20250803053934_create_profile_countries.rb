class CreateProfileCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :profile_countries do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :country, null: false, foreign_key: true

      t.timestamps
    end
    add_index :profile_countries, [:profile_id, :country_id], unique: true
  end
end
