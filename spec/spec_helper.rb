ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'
require 'support/controller_macros'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Our app is so aweome, that some of the controllers depend on the Product database to be populated.  
# So here's access to the population function for when it's needed
require Dir[Rails.root.join("config/initializers/populate_the_database.rb")].first


RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  # config.extend ControllerMacros, :type => :controller
  config.include ControllerMacros, :type => :controller 
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  
  config.infer_spec_type_from_file_location!
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "fixed" # "random"
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end
  config.before(:each) do
    DatabaseCleaner.start
  end
  config.after(:each) do
    DatabaseCleaner.clean
  end
  
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  
  config.expect_with :rspec do |c|
    # Enable expect and should
    c.syntax = [:should, :expect]
  end
end



# NOT USED
def integration_sign_in(user)
  visit "/users/sign_in" #signin_path
  fill_in :user_email, :with => user.email
  fill_in :user_password, :with => user.password
  click_button :submit
end

def create_and_sign_on_as_admin
  @user = create_admin_user

  login @user
  @user
end

def create_admin_user
  attr = {
    :name => "Admin User",
    :email => "admin@example.com",
    :password => "changeme",
    :password_confirmation => "changeme"
  }
  r = Role.new
  r.name = "admin"
  r.save
  
  @user = User.create(attr)
  @user.roles << r
  @user.save
  @user
end

def create_sale_for_user(user)
  sale = FactoryGirl.create(:sale_with_1_book_unpaid)
  sale.address = user.addresses.first
  user.sales << sale
  user.save
  sale
end


def create_address_for_user(user)
  attr = {
      :code_name => "Batman's House",
      :address1 => "4000 Prime Drive",
      :apt => "1",
      :city => "Gotham",
      :first_name => "Pillar",
      :last_name => "Slant",
      :state => "NY",
      :zip => "00001",
      :country => "US"
    }
  
  user.addresses.create(attr)
end

def create_alt_address_for_user(user)
  attr = {
      :code_name => "Batman's Hut",
      :address1 => "4001 Prime Drive",
      :apt => "1",
      :city => "Gotham",
      :first_name => "Pillar",
      :last_name => "Slant",
      :state => "NY",
      :zip => "00001",
      :country => "US"
    }
  
  user.addresses.create(attr)
end

def create_purchase_for_user(user, address, type = :unpaid)
  sale = user.sales.create(:address_id => address.id)
  sale.receipt_confirmed = Time.now if type == :paid
  sale.save
end


def create_product
  category = "Children's Picture Book"
  description = "Follow Sam as he treks from his home through a big city amassed with protesters marching for love and peace."
  thumbnail = "/images/titles/pwtd.jpg"
  material = '<a href="#">link</a>'
  qty_on_hand = 2000  # we're going to need a way to make this decrement...
  Product.create(:name => "The Parade with the Drums",
                 :sku => "0001", :category => category, 
                 :description => description, :thumbnail => thumbnail,
                 :material => material,
                 :price_usd => 18.00, :taxable => true, 
                 :shipping_cost_usd => 3.00, :qty_on_hand => qty_on_hand, 
                 :qty_ordered => 0)
end


def make_a_sale(valid_attributes)
  sale = FactoryGirl.create(:sale_with_1_book_unpaid)
  sale.user_id = valid_attributes["user_id"]
  sale.address_id = valid_attributes["address_id"]
  sale.save
  sale
  #sale = Sale.new
  #valid_attributes.each { |k, v| sale[k.to_sym] = v }
  #sale.line_items << LineItem.create!(:qty => 1, :price => 1.0)
  #sale.save
  #sale
end


def create_integration_purchase
  user_email = "a@z.com"
  primary_address = {
        "code_name"=>"My First House",
        "first_name"=>"Phill",
        "last_name"=>"Mill",
        "country"=>"United States",
        "address1"=>"123 Feather",
        "apt"=>"1",
        "city"=>"D",
        "state"=>"AL",
        "zip"=>"00001"
      }
  
  purchase_params = { 
      "line_items"=>{"0"=>{"product_sku"=>"0001", "price_spoof"=>"0.02"}},
      "products"=>{"0"=>{"shipping_price_spoof"=>"0.002", "sku"=>"0001"}},
      "user"=>{"email"=>user_email, "email_confirmation"=>user_email},
      "address"=> primary_address,
      "line_item"=>{"qty"=>"1", "discount_verification_instructions"=>""},
      "submit"=>"Proceed to Bitcoin Payment",
      "controller"=>"purchases",
      "action"=>"create"
    }
  
  post '/purchases', purchase_params

  Sale.find_by_user_id( User.find_by_email(user_email) )
end


def make_random_assortment_of_sales
  # make 5 fresh sales
  5.times do
    FactoryGirl.create(:user_with_1_book_unpaid)
  end
  
  # make 3 stale sales
  3.times do
    FactoryGirl.create(:user_with_1_stale_book)
  end
  
  # set 6 to receipt confirmed
  6.times do
    FactoryGirl.create(:user_with_1_book)
  end
  
  # set 3 to shipped
  3.times do
    FactoryGirl.create(:user_with_1_shipped_book)
  end
end

