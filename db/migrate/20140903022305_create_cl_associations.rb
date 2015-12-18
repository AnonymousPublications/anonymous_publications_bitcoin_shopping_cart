class CreateClAssociations < ActiveRecord::Migration
  def change
    create_table(:cl_associations, :id => false) do |t|
      t.integer :coupon_id
      t.integer :line_item_id
    end
    
    add_index(:cl_associations, [ :coupon_id, :line_item_id ])
  end
end
