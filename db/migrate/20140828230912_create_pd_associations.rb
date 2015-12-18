# Product/ Discount associations
class CreatePdAssociations < ActiveRecord::Migration
  def change
    create_table(:pd_associations, :id => false) do |t|
      t.integer :product_id
      t.integer :discount_id
    end
    
    add_index(:pd_associations, [ :product_id, :discount_id ])
  end
end
