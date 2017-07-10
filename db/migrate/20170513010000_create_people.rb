class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :username
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :mobile
      t.string :homephone
      t.string :address1
      t.string :address2
      t.string :address3
      t.string :postcode

      t.boolean :is_member, default: false
      t.boolean :is_active, default: false
      t.boolean :is_source, default: false
      t.boolean :is_destination, default: false

      t.boolean :is_admin, default: false
      t.boolean :is_user, default: false
      t.boolean :is_modifier, default: false

  t.string :password_digest
 t.string  :remember_token
 t.string  :activation_digest
 t.string  :reset_digest
 t.datetime  :reset_sent_at

      t.integer  :createdBy_id, index: true, foreign_key: true
      t.timestamps
    end
  end
end
