# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shipping_plan do
    name "MyString"
    shipping_base_amount "9.99"
  end
end
