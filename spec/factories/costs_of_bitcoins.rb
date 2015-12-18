# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :costs_of_bitcoin do
    qty_of_satoshi 1
    cost_in_usd "9.99"
  end
end
