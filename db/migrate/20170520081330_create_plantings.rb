class CreatePlantings < ActiveRecord::Migration
  def change
    create_table :plantings do |t|
      t.string :seedling_code, index: true, foreign_key: true
      t.foreign_key :seedlings, column: 'seedling_code', primary_key: 'seedling_code'
      t.string  :planting_code

      t.belongs_to :destination, index: true, foreign_key: true
      t.foreign_key :destinations

      t.string :dest_description

      t.point :location, :spatial => true, :srid => 4326
      t.float :x
      t.float :y
      t.integer :altitude
      t.belongs_to :projection, foreign_key:true
      t.foreign_key :projections

      t.datetime :date_planted
      t.integer :number_planted

      #Really want a separate table to survey survival over time ... 
      t.datetime :date_checked
      t.integer :number_survived

      t.text :notes

      t.integer  :createdBy_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'createdBy_id'

      t.timestamps
    end
  end
end
