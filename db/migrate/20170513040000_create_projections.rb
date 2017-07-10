class CreateProjections < ActiveRecord::Migration
  def change
    create_table :projections do |t|
       t.string :name
       t.string :proj4
       t.string :wkt
       t.integer :epsg

       t.integer  :createdBy_id, index: true, foreign_key: true
       t.foreign_key :people, column: 'createdBy_id'
       t.timestamps
    end
  end
end
