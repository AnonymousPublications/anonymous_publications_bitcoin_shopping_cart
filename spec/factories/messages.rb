# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    header "MyText"
    body "MyText"
    type ""
  end
end
