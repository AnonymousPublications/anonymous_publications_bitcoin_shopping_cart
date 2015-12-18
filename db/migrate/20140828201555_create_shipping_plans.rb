class CreateShippingPlans < ActiveRecord::Migration
  def change
    create_table :shipping_plans do |t|
      t.integer :product_id
      t.string :name
      t.decimal :shipping_base_amount

      t.timestamps
    end
  end
end
