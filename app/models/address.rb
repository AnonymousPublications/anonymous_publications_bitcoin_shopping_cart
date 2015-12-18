class Address < ActiveRecord::Base
  attr_accessible :code_name, :address1, :address2, :apt, :city, :first_name, :last_name, :state, :zip, :country, :erroneous, :original_id
  validates_presence_of :code_name, :address1, :city, :first_name, :last_name, :state, :zip, :country
  
  belongs_to :user
  has_one :sale
  has_one :retailer
  belongs_to :encryption_pair
  
  extend Importable
  
  
  def set_encryption_pair # set_encryption_pair
    self.encryption_pair = EncryptionPair.current if self.encryption_pair.nil?
  end
  
  def set_encryption_pair! # set_encryption_pair
    self.encryption_pair = EncryptionPair.current if self.encryption_pair.nil?
    self.save
  end
  
  def retailer?
    return false if retailer.nil?
    return true
  end
  
  def self.create_or_find_address(user, params)
    if params[:address_style] == "saved"
      @address = user.addresses.find(params[:sale][:address_id].to_i)
    else
      @address = Address.create_instant_address(user, params[:address])
      @address.save
    end
    @address
  end
  
  def self.create_instant_address(user, address_params)
    @address = user.addresses.new(address_params)
    @address.set_encryption_pair
    
    # bail out if there was a problem with the address
    if @address.invalid?
      flash = @address.errors
    end
    
    return @address
  end
  
  def present_code_name
    "#{code_name} - R#{id}"
  end
  
  def method_missing(method, *args)
    # if this is a _cleartext call to an existing attribute
    attr = method.to_s.sub("_cleartext","").to_sym
    if self.respond_to? attr
      do_decryption_on_attribute(attr)
    end
  end
  
  
  def do_decryption_on_attribute(attr)
    # remove all keys
    # WorkHard.remove_all_keys!
    
    add_decryption_key_if_needed
    
    raise "Could Not Find Decrypt Key.  Did we update keys and did you forget to put it in application.yml and restart the app shipping team?" if self.encryption_pair.private_key.nil?
    
    # add key in encryption_pair to the keyring
    GPGME::Key.import self.encryption_pair.private_key
    
    # Perform Decryption
    crypto = GPGME::Crypto.new
    crypto.decrypt(self.send(attr)).to_s
  end
  
  def add_decryption_key_if_needed
    
    # Read the cipher, figure out what key was used to encrypt it...
    
    if self.encryption_pair.private_key.nil?
      # Add the decryption key to the record
      self.encryption_pair.update_attributes(private_key: $DecryptionKey)
    end
    
  end
  
  
  def self.most_recently_changed_address_timestamp
    address = Address.order('updated_at DESC').limit(1).first
    address.created_at.to_json.gsub('"', "").gsub(":",".").sub("T", "_").sub("Z", "")
  end
  
  
  def self.build_address_completion_file
    @shipped_sales = Sale.current_batch_that_was_shippable
    @unshippable_sales = Sale.unshippable
    
    return_array = [ @shipped_sales.for_import_back_to_production_webserver, 
                     @unshippable_sales.for_import, 
                     convert_active_record_to_array(ReadyForShipmentBatch.last) ]
    
    config = {file_type: :address_completion_file, symmetric_key: $FrontDoorKey}
    nmd_address_completion_file = NmDatafile.new(config, *return_array)
  end
  
end
