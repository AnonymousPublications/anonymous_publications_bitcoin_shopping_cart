class CreateCoupons < ActiveRecord::Migration
  def change
    create_table :coupons do |t|
      t.integer :discount_id
      t.integer :product_id    # if this coupon applies to a specific product, then this should be set
      
      t.string :applies_to  # read :type, indicates if it applies to a whole "sale" or an individual "line_item"
      t.text :token
      t.integer :usage_limit, :default => 0
      t.boolean :enabled,     :default => true
      t.string :disabled_message
      
      t.timestamps
    end
  end
end
