# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :pricing_rule do
    case_value "MyString"
    condition "MyString"
    discount_percent "MyString"
    shipping_modifier "MyString"
    discount_id 1
    shipping_plan_id 1
  end
end
