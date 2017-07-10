class AddFkToPeople < ActiveRecord::Migration
  def change
    change_table :people do |t|
        t.foreign_key :people, column: 'createdBy_id'

    end

  end
end
