class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.integer :original_id
      t.integer :sale_id
      t.integer :discounted_item_id
      t.string :product_sku
      
      t.integer :qty
      t.decimal :price             # this is the actual price at purchase according to exchange rates in BTC (unless currency_used is USD)

      t.integer :shipping_cost_btc, :default => 0   # TODO:  remove these in favor of shipping_cost?
      t.decimal :shipping_cost_usd, :default => 0.0
      
      t.decimal :shipping_cost, :default => 0.0
      t.decimal :discounted_amount
      
    
      t.string :currency_used
      
      t.decimal :price_extend, :default => 0.0     # price_after_qty_calc # TODu, remove this, make calculated?
      t.decimal :price_after_product_discounts
      
      t.text :description

      t.decimal :discount         # TODO:  Remove since unused

      t.timestamps
    end
    
    add_index :line_items, :sale_id
  end
  
end
