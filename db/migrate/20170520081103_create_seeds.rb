class CreateSeeds < ActiveRecord::Migration
  def change
    create_table :seeds do |t|

      t.belongs_to :collection, index: true, foreign_key: true
      t.foreign_key :collections
      t.string  :seed_code
      t.index  :seed_code, unique: true
      t.datetime :date_sown
      t.integer :number_sown
      t.boolean :is_active, default: true
      t.text :notes

      t.integer  :createdBy_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'createdBy_id'
      t.timestamps
    end
  end
end
