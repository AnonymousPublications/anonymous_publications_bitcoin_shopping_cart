class CreateEncryptionPairs < ActiveRecord::Migration
  def change
    create_table :encryption_pairs do |t|
      t.integer :original_id
      t.text :public_key
      t.text :private_key
      t.string :test_value
      t.boolean :tested

      t.timestamps
    end
  end
end
