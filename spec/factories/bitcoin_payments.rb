# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bitcoin_payment do
    value "1"
    input_address "MyString"
    confirmations "6"
    sequence(:transaction_hash) {|n| User.random_string(8) + "SZTAMyLGrUfDr3R3MvcMWVTmDf#{n}" }
    input_transaction_hash "MyString"
    destination_address ENV['SHOPPING_CART_WALLET']
    # sale_id ""
    raw_callback "MyString"
  end
end
