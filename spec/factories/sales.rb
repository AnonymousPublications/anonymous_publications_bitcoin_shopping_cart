# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sale do
    currency_used "BTC"
    
    # Set these in special cases...
    sequence(:receipt_confirmed) {|n| Time.zone.now }
    # downloaded "2013-12-12"
    # shipped "2013-12-12"
    
    
    # These values are actually calculated values... optimize later
    # sale_amount "9.99"
    # tax_amount "9.99"
    shipping_amount "0.00"
    
    after(:build) do |sale|
      sale.user = FactoryGirl.create(:user_with_1_address)
      sale.address = sale.user.addresses.first
      sale.checkout_wallet = FactoryGirl.create(:checkout_wallet)
      ubw = UtilizedBitcoinWallet.find_by_wallet_address(ENV['SHOPPING_CART_WALLET'])
      ubw = FactoryGirl.create(:utilized_bitcoin_wallet, wallet_address: ENV['SHOPPING_CART_WALLET']) if ubw.nil?
      sale.utilized_bitcoin_wallet = ubw
    end
    
  end
  
  factory :sale_with_1_book, :parent => :sale do
    line_items  { |items| [ items.association(:line_item_1_book)
      ]}
    
    after(:build) do |sale|
      @btc_payment_params = { "secret_authorization_token" => "babe" }
      bp = FactoryGirl.create(:bitcoin_payment)
      bp.value = WorkHard.convert_back_to_satoshi(sale.total_amount)
      sale.bitcoin_payments << bp
      bp.save
      
      sale.calculate_shipping_amount
    end
  end
  
  factory :sale_with_2_books, :parent => :sale do
    line_items  { |items| [ items.association(:line_item_2_books),
                            #items.association(:line_item_discount)
      ]}
    
    after(:build) do |sale| 
      sale.checkout_wallet = FactoryGirl.create(:checkout_wallet)
      sale.calculate_shipping_amount
    end
  end
  
  factory :sale_with_5_books, :parent => :sale do
    line_items  { |items| [ items.association(:line_item_5_books),
                            #items.association(:line_item_discount)
      ]}
    
    after(:build) do |sale| 
      sale.checkout_wallet = FactoryGirl.create(:checkout_wallet)
      sale.calculate_shipping_amount
    end
  end
  
  factory :sale_with_10_books, :parent => :sale do
    line_items  { |items| [ items.association(:line_item_10_books),
                            #items.association(:line_item_discount)
      ]}
    
    after(:build) do |sale| 
      sale.checkout_wallet = FactoryGirl.create(:checkout_wallet)
      sale.calculate_shipping_amount
    end
  end
  
  factory :sale_with_1_book_unpaid, :parent => :sale do
    receipt_confirmed nil
    
    line_items  { |items| [ 
      items.association(:line_item_1_book)
      ]}
    
    after(:build) do |sale| 
      sale.checkout_wallet = FactoryGirl.create(:checkout_wallet)
      sale.calculate_shipping_amount
    end
  end
  
  
end


