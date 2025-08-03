class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :username, null: false
      t.text :bio
      t.date :date_of_birth
      t.boolean :is_rider, default: false
      t.boolean :is_photographer, default: false
      t.references :user, null: true, foreign_key: true

      t.timestamps
    end
    
    add_index :profiles, :username, unique: true
  end
end
