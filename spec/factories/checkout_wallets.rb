# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :checkout_wallet do
    sequence(:input_address) {|n| "1MKaTLjTSZTAMyLGrUfDr3R3MvcMWVTmDf" }
    secret_authorization_token "babe"
    transaction_hash "MyString"
    input_transaction_hash "MyString"
    destination_address ENV['SHOPPING_CART_WALLET']
  end
end
