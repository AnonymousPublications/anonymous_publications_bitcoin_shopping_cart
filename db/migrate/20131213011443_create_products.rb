class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.integer :original_id
      t.integer :shipping_plan_id
      t.string :name
      t.string :description
      t.string :material
      t.string :digital_copy
      t.string :thumbnail

      t.string :sku
      t.string :category
      t.boolean :is_discount           # TODu: remove, not used
      t.decimal :price_usd
      t.boolean :taxable
      t.decimal :shipping_cost_usd
      t.decimal :qty_on_hand
      t.decimal :qty_ordered
      
      t.decimal :pounds                # for mail calculations
      t.decimal :length
      t.decimal :width
      t.decimal :height
      
      t.boolean :required_by_system     # TODu: stuff will break with out this product, do not delete

      t.timestamps
    end

    add_index :products, :sku,                :unique => true
  end
end
