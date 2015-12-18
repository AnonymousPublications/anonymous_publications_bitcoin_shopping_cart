# This class was created to store which bitcoin wallet the user's payment
# would be forwarded to.  This record is important but it should really
# be stored on the user's checkout wallet... but, because those records
# aren't transfered to the shipping crew, a separate table was created...
# This is bad design... TODO:  Delete this record and see what happens on the
# printer machine... maybe I'm missing something
class UtilizedBitcoinWallet < ActiveRecord::Base
  attr_accessible :wallet_address
  
  has_many :sales
  
  extend Importable
end
