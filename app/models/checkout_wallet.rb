class CheckoutWallet < ActiveRecord::Base
  attr_accessible :input_address, :input_transaction_hash, :transaction_hash, 
    :value_needed, :secret_authorization_token, :destination_address, 
    :last_manual_lookup, :last_successful_manual_lookup
  belongs_to :sale
  validates_presence_of :secret_authorization_token
  
  # This is a function that indicates how much payment has been sent to the payment hash
  # It checks our database for all bitcoin_payments that have been sent for the specified address
  def value_paid
    self.sale.bitcoin_payments.select{|x| x.confirmations >= 6}.map{|x| x['value']}.sum
  end
  
  def unconfirmed_value_paid
    bitcoin_payments_sum = self.sale.bitcoin_payments.map{|x| x.value}.sum
    # _that_went_into_the_checkout_wallet_at_least
    technical_bitcoin_payments = self.sale.technical_bitcoin_payments.map{|x| x.value}.sum
    return [bitcoin_payments_sum, technical_bitcoin_payments].max
  end

  def fully_paid?
    (value_paid >= value_needed)
  end
  
  def value_needed
    return sale.total_amount unless sale.nil?
  end
  
  # This function determines if the user should see that they've completed their payment...
  # It will show them they've paid, but internally, the app will wait for the 6 confirmations
  # before shipping considers things paid
  def technically_paid?
    unconfirmed_value_paid >= value_needed
  end
  
  def payment_status
    checkout_wallet = self
    return :fully_paid if checkout_wallet.fully_paid?
    return :partially_paid if !checkout_wallet.fully_paid? and !checkout_wallet.sale.bitcoin_payments.empty?
    return :waiting_for_payment
  end
  
  def having_trouble_doing_manual_lookups?
    if last_successful_manual_lookup.nil?
      return false # if we haven't made our first attempted lookup, then things are fine afawk
    elsif last_successful_manual_lookup.nil?
      return true
    else
      return (Time.zone.now - last_successful_manual_lookup)/60/60/24 > 1.0
    end
  end

  def self.make_callback_uri(destination_wallet, sale_id, secret_auth_token)
    raise "$BitcoinCallbackDomain not set properly" if $BitcoinCallbackDomain.empty? and !$IsDebuggingResponses
    callback_uri = $BitcoinCallbackDomain + "/bitcoin_payments_callback"

    callback_uri = callback_uri + "?sale_id=#{sale_id}&secret_authorization_token=#{secret_auth_token}"
    callback_uri
  end
  
  def calculate_if_payment_complete
    total_bitcoin_payments = sale.bitcoin_payments.map{|x| x.value}.sum
    if total_bitcoin_payments >= value_needed
      sale.receipt_confirmed = Time.now
      sale.save
    else
      sale.receipt_confirmed = nil
      sale.save
    end
  end

  # Put this online and generate a fake callback uri, then use it and see what the app fuckin does...
  def simulate_callback_uri
    wallet = ENV["SHOPPING_CART_WALLET"]
    # add in info like destination_address and stuff
    base_uri = CheckoutWallet.make_callback_uri(wallet, self.sale.id, self.secret_authorization_token)
    extras = "&anonymous=false&value=#{value_needed}&input_address=#{self.input_address}&confirmations=6&transaction_hash=ltxhashl&input_transaction_hash=intxhash&destination_address=#{wallet}&address=#{wallet}"
    base_uri + extras
  end
  
  def self.request_checkout_wallet(destination_wallet, sale, secret_auth_token)
    sale.set_utilized_bitcoin_wallet(destination_wallet)
    
    callback_uri = $BitcoinCallbackDomain + "/bitcoin_payments_callback"

    callback_uri = CGI.escape(CheckoutWallet.make_callback_uri(destination_wallet, sale.id, secret_auth_token))
    bitcoin_wallet_creation_address = "https://blockchain.info/api/receive?method=create&address=#{destination_wallet}&callback=#{callback_uri}"

    if $IsDebuggingResponses
      payment_wallet = eval $TestPaymentWallet # TODO Switch to JSON.parse() instead of eval
    else
      payment_wallet = HTTParty.get(bitcoin_wallet_creation_address).body
      payment_wallet = JSON.parse(payment_wallet)
    end

  end
  
  # #pew... read #new
  def self.pew(sale)
    sale.save
    
    wallet = ENV["SHOPPING_CART_WALLET"]
    # CREATE BITCOIN CHECKOUT WALLET
    secret_auth_token = generate_secret_authorization_token
    payment_wallet = CheckoutWallet.request_checkout_wallet(wallet, sale, secret_auth_token)
    # TODO:  payment_wallet is something that can't have select called on it
    # Create the payment record...
    checkout_wallet_params = (payment_wallet.select{|k| k == "input_address" }).merge({"value_needed" => sale.total_amount, "secret_authorization_token" => secret_auth_token, "destination_address" => wallet })
    sale.create_checkout_wallet(checkout_wallet_params)
  end
  
  def self.generate_secret_authorization_token
    SecureRandom.hex.to_s.chars.shuffle.join.to_s
  end
  
end
