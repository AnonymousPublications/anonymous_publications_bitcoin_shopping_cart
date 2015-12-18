class CreateRetailers < ActiveRecord::Migration
  def change
    create_table :retailers do |t|
      t.integer :address_id
      t.string :name
      t.string :email
      t.string :phone
      t.string :fax
      t.string :map_link
      t.text :notes

      t.timestamps
    end
  end
end
