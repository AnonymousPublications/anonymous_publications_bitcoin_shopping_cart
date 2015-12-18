# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :coupon do
    token "MyText"
    usage_limit 1
    enabled false
    disabled_message "MyString"
    discount_id 1
  end
end
