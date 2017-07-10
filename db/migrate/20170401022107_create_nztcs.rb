class CreateNztcs < ActiveRecord::Migration
  def change
    create_table :nztcs do |t|
      t.string :name_and_authority
      t.index :name_and_authority, unique: true
      t.string :umbrella_category
      t.string :conservation_status
      t.string :trend
      t.string :qualifiers
    end
  end
end
