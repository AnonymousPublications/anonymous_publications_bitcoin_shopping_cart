class CreatePricingRules < ActiveRecord::Migration
  def change
    create_table :pricing_rules do |t|
      t.string :case_value
      t.string :condition
      t.string :discount_percent
      t.string :shipping_modifier
      t.integer :discount_id
      t.integer :shipping_plan_id

      t.timestamps
    end
  end
end
