class EncryptionPair < ActiveRecord::Base
  attr_accessible :private_key, :public_key, :test_value, :tested
  
  has_many :addresses
  
  extend Importable
  
  # TODu:  Not finished?.. wtf...
  def self.current
    self.find_or_create_by_public_key($EncryptionKey)
  end
  
  
end
