# Allows you to import records from a hash
module Importable
  
  def import_from_hash_to_shipping(hash)
    hash = hash.extend(Importable).backup_id
    
    s = self.find_by_original_id(hash["original_id"])
    s = self.new if s.nil?

    hash.each do |k,v|
      next if k == "id" # skip id field since it can't be specified anyway
      
      s[k] = v
    end
    s.save
  end
  
  def backup_id
    self["original_id"] = self["id"]
    self
  end
  
  def for_import
    source_duplicate = dup_source
    
    source_duplicate.collect { |x| {"id" => x["original_id"]}}
  end
  alias :for_import_back_to_production_webserver :for_import
  
  def convert_active_record_to_array(ar)
    JSON.load(ar.to_json)
  end
  
  def self.convert_active_record_to_array(ar)
    JSON.load(ar.to_json)
  end
  
  def dup_source
    array = []
    if defined?(all)  # this makes it so it works on arrays OR active record relations
      all.each do |x|
        array << convert_active_record_to_array(x)
      end
    else # is array
      self.each do |x|
        array << convert_active_record_to_array(x)
      end
    end
    array
  end
  
  
  # This method goes through all the Sales of the current batch and
  # set's the address_id to be equal to Address.find(address.original_id)
  # NOTE: this process must also be reversed upon import... maybe more tables would be good...
  #
  # When used as Sale.reassociate_with_adjusted_ids_for!(Address, sales)...
  # it re-writes the sales records to have the proper address_id value
  def reassociate_with_adjusted_ids_for!(model, imported_records)
    rfsb_id = ReadyForShipmentBatch.last.id
    column_to_correct = get_models_foreign_key_name(model)

    records = find_imported_records(imported_records)
    
    records.each do |record|  # Sale records
      original_column_value = record.send(column_to_correct)
      
      # For testing purposes, we create a spoof sale record
      # which has no association with an address, so the algo should
      # not make an attempt if no matching record can be found for this record
      next if model.find_by_original_id(original_column_value).nil?
      
      
      desired_column_value = model.find_by_original_id(original_column_value).id
      record.send(column_to_correct+"=", desired_column_value)
      record.save
    end
  end
  
  # returns an array of active_record objects
  def find_imported_records(imported_records)
    array = []
    imported_records.each do |record|
      array << self.find_by_original_id(record["id"])
    end
    array
  end
  
  # for Address, returns address_id
  # for ReadyForShipmentBatchId, returns ready_for_shipment_batch_id
  def get_models_foreign_key_name(model)
    return "ready_for_shipment_batch_id" if model.name == "ReadyForShipmentBatch" # TODu: do properly
    return "utilized_bitcoin_wallet_id" if model.name == "UtilizedBitcoinWallet"
    model.name.downcase + "_id"
  end
  
end














