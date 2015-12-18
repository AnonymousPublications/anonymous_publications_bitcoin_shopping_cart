class CreateBitcoinPayments < ActiveRecord::Migration
  def change
    create_table :bitcoin_payments do |t|
      t.integer :original_id
      t.integer :user_id
      t.integer :sale_id
      t.integer :value, :limit => 8
      t.string :input_address
      t.integer :confirmations
      t.string :transaction_hash
      t.string :input_transaction_hash
      t.string :destination_address
      t.string :raw_callback

      t.timestamps
    end
    
    add_index :bitcoin_payments, :input_address
    add_index :bitcoin_payments, :sale_id
    add_index :bitcoin_payments, :transaction_hash, :unique => true
  end
end
