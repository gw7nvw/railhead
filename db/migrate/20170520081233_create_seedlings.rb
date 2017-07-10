class CreateSeedlings < ActiveRecord::Migration
  def change
    create_table :seedlings do |t|
      t.string  :seedling_code
      t.index  :seedling_code, unique: true
      t.string :seed_code, index: true, foreign_key: true
      t.foreign_key :seeds, column: 'seed_code', primary_key: 'seed_code'
      t.datetime :date_potted
      t.integer :number_potted
      t.integer :number_died
      t.integer :current_stock
      t.text :notes
      t.boolean :is_active, default: true

      t.integer  :createdBy_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'createdBy_id'

      t.timestamps
    end
  end
end
