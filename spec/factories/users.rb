# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email)      { |n| "person#{User.random_string(4)}-#{n}@example.com" }
    password "password"
    
    after(:build) do |user| 
      rand(1..4).times { user.addresses << FactoryGirl.create(:address) }
    end
  end
  
  factory :admin_user, :parent => :user do
    after(:build) do |user|
      user.add_role :admin
    end
  end
  
  factory :user_with_1_address, :parent => :user do
    after(:build) do |user|
      user.addresses.each.with_index do |address, i|
        Address.find(address.id).delete unless i == 0
      end
    end
  end
  
  
  factory :user_with_1_book, :parent => :user do
    after(:build) do |user|
      setup_a_user_with_books(user, :sale_with_1_book)
    end
  end
  
  factory :user_with_2_books, :parent => :user do
    after(:build) do |user|
      setup_a_user_with_books(user, :sale_with_2_books)
    end
  end
  
  factory :user_with_5_books, :parent => :user do
    after(:build) do |user|
      setup_a_user_with_books(user, :sale_with_5_books)
    end
  end
  
  factory :user_with_10_books, :parent => :user do
    after(:build) do |user|
      setup_a_user_with_books(user, :sale_with_10_books)
    end
  end
  
  factory :user_with_1_book_unpaid, :parent => :user do
    after(:build) do |user|
      s = FactoryGirl.build(:sale_with_1_book_unpaid)
      s.address_id = user.addresses.first.id
      user.sales << s
      s.save
      user.save
    end
  end
  
  # :user_with_1_book
  factory :user_with_1_shipped_book, :parent => :user do
    after(:build) do |user|
      setup_a_user_with_books(user, :sale_with_1_book)
      s = user.sales.first
      s.shipped = Time.now
      s.save
    end
  end
  
  # :user_with_1_stale_book
  factory :user_with_1_stale_book, :parent => :user do
    after(:build) do |user|
      s = FactoryGirl.build(:sale_with_1_book_unpaid)
      s.address_id = user.addresses.first.id
      
      
      s.created_at = 4.weeks.ago
      s.updated_at = 4.weeks.ago
      user.sales << s
      
      s.save
      user.save
    end
  end
  
end

def setup_a_user_with_books(user, books_symbol)
  user.sales << FactoryGirl.create(books_symbol)
  s = user.sales.first
  s.address_id = user.addresses.first.id
  
  b = FactoryGirl.build(:bitcoin_payment)
  b.input_address = s.checkout_wallet.input_address
  s.bitcoin_payments << b
  
  b.save
  s.save
  user.save
end
