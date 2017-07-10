class CreateAreas < ActiveRecord::Migration
  def change
    create_table :areas do |t|
      t.string :name
      t.text :notes
      t.polygon :boundary, :spatial => true, :srid => 4326
    end
  end
end
