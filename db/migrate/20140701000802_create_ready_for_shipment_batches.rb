class CreateReadyForShipmentBatches < ActiveRecord::Migration
  def change
    create_table :ready_for_shipment_batches do |t|
      t.integer :original_id
      t.integer :sale_id
      t.string :batch_stamp
      t.string :sf_integrity_hash   # shippable file integrity hash (on shipping machine)
      t.string :acf_integrity_hash   # address completion file integrity hash (on webserver)
      

      t.timestamps
    end
    
    add_index :ready_for_shipment_batches, :batch_stamp,                :unique => true
  end
end
