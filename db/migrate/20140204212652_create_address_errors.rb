class CreateAddressErrors < ActiveRecord::Migration
  def change
    create_table :address_errors do |t|

      t.timestamps
    end
  end
end
