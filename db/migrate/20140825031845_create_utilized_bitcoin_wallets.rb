class CreateUtilizedBitcoinWallets < ActiveRecord::Migration
  def change
    create_table :utilized_bitcoin_wallets do |t|
      t.integer :original_id
      t.text :wallet_address

      t.timestamps
    end
  end
end
