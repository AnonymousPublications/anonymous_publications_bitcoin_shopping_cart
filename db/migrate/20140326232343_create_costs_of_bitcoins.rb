class CreateCostsOfBitcoins < ActiveRecord::Migration
  def change
    create_table :costs_of_bitcoins do |t|
      t.integer :qty_of_satoshi, :limit => 8
      t.decimal :cost_in_usd

      t.timestamps
    end
  end
end
