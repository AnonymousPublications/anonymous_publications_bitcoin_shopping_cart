class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.integer :encryption_pair_id
      t.integer :original_id
      t.text :code_name
      t.integer :user_id
      t.text :first_name
      t.text :last_name
      t.text :address1
      t.text :address2
      t.text :apt
      t.text :zip
      t.text :city
      t.text :state
      t.text :country
      t.text :phone
      
      t.boolean :erroneous, :default => false
      
      t.timestamps
    end
  end
end
