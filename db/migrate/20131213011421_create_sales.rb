class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.integer :original_id
      t.integer :user_id
      t.integer :address_id
      t.integer :ready_for_shipment_batch_id
      t.integer :utilized_bitcoin_wallet_id
      # t.integer :checkout_wallet_id
      t.boolean :prepped, :default => false
      t.datetime :shipped
      t.datetime :receipt_confirmed
      t.datetime :delivery_acknowledged
      t.string :currency_used, :default => "BTC"
      t.decimal :sale_amount
      # t.decimal :tax_amount
      t.decimal :shipping_amount
      
      t.decimal :total_amount

      t.timestamps
    end
  end
end
