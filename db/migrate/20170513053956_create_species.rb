class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :code
      t.index :code
      t.string :genus
      t.string :species
      t.string :common_name
      t.string :nztcs_name
      t.boolean :is_active

      t.integer  :createdBy_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'createdBy_id'
      t.foreign_key :nztcs, column: 'nztcs_name', primary_key: 'name_and_authority'

      t.timestamps
    end
  end
end
