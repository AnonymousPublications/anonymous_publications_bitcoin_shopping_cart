class CreateCheckoutWallets < ActiveRecord::Migration
  def change
    create_table :checkout_wallets do |t|
      t.integer  :sale_id
      t.integer  :value_needed, :limit => 8
      t.string   :secret_authorization_token
      t.string   :input_address
      t.string   :transaction_hash
      t.string   :input_transaction_hash
      t.string   :destination_address
      t.datetime :last_manual_lookup
      t.datetime  :last_successful_manual_lookup
      
      t.timestamps
    end
  end
end
