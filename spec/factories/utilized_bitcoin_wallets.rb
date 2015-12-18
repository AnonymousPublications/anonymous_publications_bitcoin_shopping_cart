# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :utilized_bitcoin_wallet do
    sequence(:wallet_address) {|n| User.random_string(8) + "SZTAMyLGrUfDr3R3MvcMWVTmDf#{n}" }
  end
end
