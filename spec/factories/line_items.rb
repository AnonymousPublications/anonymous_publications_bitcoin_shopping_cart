# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :line_item do
    currency_used "BTC"
    product_sku "0001"
    qty 1
    
    after(:build) do |line_item|
      # line_item.product = Product.find_by_sku("0001")
      # line_item.product.association
      # line_item.product_sku = "0001"
      
      #sale.checkout_wallet = FactoryGirl.create(:checkout_wallet)
    end
  end
  
  factory :line_item_1_book, :parent => :line_item  do
    qty 1
    price 4500000.0
    price_extend 4500000.0
  end
  
  factory :line_item_2_books, :parent => :line_item  do
    qty 2
    price 4500000.0
    price_extend 9000000.0
  end
  
  factory :line_item_5_books, :parent => :line_item  do
    qty 5
    price 4500000.0
    price_extend 22500000.0
  end
  
  factory :line_item_10_books, :parent => :line_item  do
    qty 10
    price 4500000.0
    price_extend 45000000.0
  end
  
  factory :line_item_discount, :parent => :line_item do
    qty 1
  end
end
