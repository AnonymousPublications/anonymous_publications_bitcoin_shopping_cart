# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :encryption_pair do
    public_key "MyText"
    private_key "MyText"
    test_value "MyString"
    tested false
  end
end
