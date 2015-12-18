class CreateDiscounts < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.integer :original_id
      t.string :name
      t.string :discount_type
      t.string :applies_to          # TODu:  implement this, refers to if the discount goes to a line_item or entire sale
      t.boolean :active             # TODu: Delete me, not used

      t.timestamps
    end
  end
end
