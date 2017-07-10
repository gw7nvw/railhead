class CreateDestinations < ActiveRecord::Migration
  def change
    create_table :destinations do |t|
      t.string :name
      t.string :owner
      t.string :legal_status
      t.integer :contact_person_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'contact_person_id'
      t.string :property_address1
      t.string :property_address2
      t.string :property_address3
      t.point :location, :spatial => true, :srid => 4326
      t.float :x
      t.float :y
      t.belongs_to  :projection, foreign_key: true
      t.foreign_key :projections
      t.integer :altitude
      t.polygon :boundary, :spatial => true, :srid => 4326
      t.text :notes
      t.boolean :is_active, :default => true

      t.integer  :createdBy_id, index: true, foreign_key: true
      t.foreign_key :people, column: 'createdBy_id'

      t.timestamps
    end
  end
end
