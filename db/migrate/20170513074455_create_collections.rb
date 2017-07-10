class CreateCollections < ActiveRecord::Migration
  def change
    create_table :collections do |t|
      t.string :source_description
      t.belongs_to :source, index: true, foreign_key:true
      t.foreign_key :sources, column: 'source_id'

      t.datetime :date
      t.point :location, :spatial => true, :srid => 4326
      t.float :x
      t.float :y
      t.integer :altitude
      t.belongs_to :projection, foreign_key:true
      t.foreign_key :projections
      t.string :no_plants_sampled
      t.string :no_collected
      t.integer :current_stock
      t.boolean :is_seeds, default: true
      t.boolean :is_cuttings, default: false
      t.integer :team_lead_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'team_lead_id'
      t.string :team_members
      t.string :species_code, index: true, foreign_key: true
      t.string :storage
      t.text :notes
      t.boolean :is_active, default: true

      t.integer :createdBy_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'createdBy_id'
 
      t.timestamps
    end
  end
end
