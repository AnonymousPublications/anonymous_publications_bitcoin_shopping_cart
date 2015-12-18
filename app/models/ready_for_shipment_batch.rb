class ReadyForShipmentBatch < ActiveRecord::Base
  attr_accessible :batch_stamp, :sf_integrity_hash, :acf_integrity_hash
  has_many :sales
  
  validates :batch_stamp, :uniqueness => true
  
  extend Importable
  
  # indicates if the rfsb has been sent to the shipping machine, and then been recieved from the
  # shipping machine back to the webserver.  We know this if both sf and acf integrity_hashes are set
  # on the object
  def cycle_complete?
    !self.sf_integrity_hash.nil? and !self.acf_integrity_hash.nil?
  end
  
  def mark_non_erroneous_as_shipped
    self.sales.each do |sale|
      if !sale.erroneous
        sale.shipped = Time.zone.now # TODu: Time of last address completion file build
        sale.prepped = false
        sale.save
      end
    end
  end

  # TODu:  Look for efficient way of hashing a table
  # we would want sale#last_modified_date, sale#address#last_modified_date 
  def self.calculate_ready_for_shipment_hash
    # determine blah...
    return "" if Sale.find_latest_confirmed_sale.nil?
    #_latest_confirmation_timestamp = Sale.latest_payment_confirmation_timestamp
    _latest_confirmed_sales_update_timestamp = Sale.latest_confirmed_sales_update_timestamp  # can't use confirmed_at, must use updated_at since erroneous sales sometimes come back
    _id = Sale.find_latest_confirmed_sale.id.to_s
    _latest_confirmed_sales_update_timestamp + _id
  end
  
  # creates a new batch stamp or finds an existing one with the matching batch_stamp
  def self.gen
    rfsb = self.find_by_batch_stamp(calculate_ready_for_shipment_hash)
    if rfsb.nil?
      rfsb = self.create(batch_stamp: calculate_ready_for_shipment_hash)
    end
    rfsb
  end
  
  #def self.gen_build
  #  rfsb = self.new(batch_stamp: calculate_ready_for_shipment_hash)
  #  rfsb.created_at = Time.zone.now
  #  rfsb.updated_at = Time.zone.now
  #  rfsb
  #end
  
end
