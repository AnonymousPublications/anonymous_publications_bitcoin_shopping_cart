# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product do
    sku "MyString"
    category "MyString"
    price_usd "9.99"
    taxable false
    shipping_cost_usd "9.99"
    qty_on_hand "9.99"
    qty_ordered "9.99"
  end
end
