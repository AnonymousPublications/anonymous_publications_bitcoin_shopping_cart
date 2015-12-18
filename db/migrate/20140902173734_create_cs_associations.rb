class CreateCsAssociations < ActiveRecord::Migration
  def change
    create_table(:cs_associations, :id => false) do |t|
      t.integer :coupon_id
      t.integer :sale_id
    end
    
    add_index(:cs_associations, [ :coupon_id, :sale_id ])
  end
end
