# This model is populated exclusively by blockchain.info everytime a payment wallet is paid
class BitcoinPayment < ActiveRecord::Base
  attr_accessible :confirmations, :destination_address, :input_address, 
                    :input_transaction_hash, :raw_callback, :sale_id, 
                    :user_id, :transaction_hash, :value, :test, 
                    :secret_authorization_token
  attr_accessor :test
  belongs_to :sale
  belongs_to :user
  
  # belongs_to :sale, :class_name => "Sale", :foreign_key => "technical_bitcoin_payment_id"
  
  def self.conduct_lookup_of_outstanding_partial_confirmations
    sales = Sale.where(receipt_confirmed: nil)
    
    sales.each do |sale|
      sale.get_confirmed_payments
    end
  end
  
end

