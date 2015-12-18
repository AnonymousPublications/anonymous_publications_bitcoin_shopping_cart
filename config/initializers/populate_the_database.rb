# This initializer sets up the models in the database 
# It will need to be modified obviously if we implement creating products
# within the actual web app



# this snip is for debugging the app without using SSL... needed on nitrous.io
# require 'openssl'
# OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE



def populate_stories

  b1 = <<END
We're pleased to share with you that, as a birthday activity, Jeremy Hammond was able to give 30 hand selected people a copy of Anonymous' new activist children's <a href="http://imgur.com/a/j3thx">book</a>.  That makes one gift for each year Jeremy Hammond has been alive; last January 8th was his 30th birthday of course.  

It is a bitter sweet story to some, as that Jeremy is unable to actually receive the book himself due to the human rights work and clever shenanigans he valiantly performed with the notorious blackhat group, lulzsec.  

You can read more on the story <a href="http://thecryptosphere.com/2015/01/08/anonymous-wishes-jeremy-hammond-happy-birthday-with-childrens-book-project/">TheCryptosphere</a> and <a href="http://theantimedia.org/political-prisoner-jeremy-hammonds-birthday-gift-world/">TheAntimedia</a>.
END

  Story.create(date: "Jan 14th, 2015 ",
               author: "",
               header: "Jeremy Hammond Gifts 30 Copies of Activist Children's Book",
               body: b1,
               img: "/images/2013-11-19-jeremyhammond.jpg")

  b2 = <<END
Anonymous Publication's cryptographically secure website is now in an operational state. Addresses are encrypted using asymmetric key encryption before they are sent to the server. Once on the server, they remain unreadable. The address values can only be decrypted with the private key which remains on our offline computers connected to our label printer.

Bitcoin is working excellently as a transactional currency. Thanks to it's low price, it is now cheaper than ever to conduct financial transactions without needing to register anyone team member's identity with an external authority.

Our merchant account was originally hosted at Digital Ocean, but they adopted a policy against anonymity and shut our server down while it was still in the early alpha phases of development and testing. We are currently on Heroku, and would like to stay with them if we can work out the SEO problems we're faced with and are able to compensate them (or an alternative) with bitcoins.

The source code to our merchant account will be made public in the following days once the code is cleaned up and ready for community presentation.  In the mean time, we'll be looking for a few extra ruby devs to take a peak at the code before we release it publicly.
END
  
  Story.create(date: "Jan 14th, 2015",
               author: "",
               header: "About Our Bitcoin Based Web App",
               body: b2,
               img: "/images/bitcoin-logo-cyan_i.png")

end

def populate_products
  populate_discounts
  populate_shipping_plans
  
  Product.delete_all
  
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
  
  # TODu
  # there should only be 1 discount product!  Their description's and display name's should be set in the LineItem record
  # this spot should only hold their sku, their technical name, and any default price values and their discountyness
                 
                 
  # Generic Discount
  Product.create(:name => "Discount",
                 :sku => "0002", :category => "discount", 
                 :description => "Discount",
                 :is_discount => true,
                 :price_usd => 0.00, :taxable => false, 
                 :shipping_cost_usd => 0.00, :qty_on_hand => -1, 
                 :qty_ordered => 0)               
  
  
  # Generic Product
  Product.create(:name => "Misc.",
                 :sku => "0000", :category => "Product", 
                 :description => "Misc. Product",
                 :price_usd => 0.00, :taxable => false, 
                 :shipping_cost_usd => 0.00, :qty_on_hand => -1, 
                 :qty_ordered => 0)
  
                 

  
  populate_discount_specifications
  populate_coupons
end


def populate_retailers
  Retailer.all.each do |retailer|
    begin
      Address.find(retailer.address_id).delete 
    rescue
    end
  end and Retailer.delete_all
  
  #make_retailer(
  #  address1: "", zip: 00000, city: "", state: "", country: "",
  #  name: "", email: "", website: "",
  #  phone: "", fax: "", map_link: "",
  #  notes: "")
  
  make_retailer(
    address1: "258 Lincoln Mall Dr", zip: 60443, city: "Matteson", state: "Il ", country: "US",
    name: "Azizi Books", email: "info@azizibooks.com", website: "www.azizibooks.com",
    phone: "(708) 283-9850", fax: "", map_link: "https://google.com",
    notes: "Far out of the city, but not too far.  Community based book store.")
  
  make_retailer(
    address1: "2115 West 21st Street", zip: 55405, city: "Minneapolis", state: "Mn", country: "US",
    name: "Birchbark Books", email: "info@birchbarkbooks.com",  website: "birchbarkbooks.com", 
    phone: "612-374-4023", fax: "612-374-4090", map_link: "https://google.com",
    notes: "Nice store.  Doesn't serve coffee.  Virtually hidden from highways.")
end

def make_retailer(hash)
  a = Address.create(first_name: "retailer", last_name: "retailer", 
                     code_name: hash[:name], address1: hash[:address1],
                     zip: hash[:zip], city: hash[:city], state: hash[:state], country: hash[:country] )
  Retailer.create(:address_id => a.id,
                  :name => hash[:name],
                  :email => hash[:email],
                  :phone => hash[:phone],
                  :fax => hash[:fax],
                  :map_link => hash[:map_link],
                  :notes => hash[:notes])
end


def ui_testing_setup
  test_populate_users
end

def refresh_database
  User.delete_all
  Sale.delete_all
  CheckoutWallet.delete_all
  Address.delete_all
  LineItem.delete_all
  BitcoinPayment.delete_all
  
  populate_retailers
  create_system_users
end

def test_populate_users
  User.delete_all
  Sale.delete_all
  CheckoutWallet.delete_all
  Address.delete_all
  LineItem.delete_all
  BitcoinPayment.delete_all
  
  populate_products
  
  
  create_system_users
  
  30.times do
    FactoryGirl.create(:user_with_1_book)
  end
  
  10.times do
    FactoryGirl.create(:user_with_2_books)
  end
  
  10.times do
    FactoryGirl.create(:user_with_5_books)
  end
  
  2.times do
    FactoryGirl.create(:user_with_10_books)
  end
end

def create_system_users
  # find them all and delete them
  system_user_definitions = YAML.load(ENV["DEFAULT_USERS"].dup)
  system_user_emails = system_user_definitions.collect {|n| n["email"]}
  
  system_user_emails.each do |email|
    old_u = User.find_by_email(email)
    deep_delete_user(old_u) unless old_u.nil?
  end
  
  puts 'SYSTEM USERS'
  system_user_definitions.each do |user_def|
    puts 'user: ' << user_def["name"]
    u = User.create(
      :name => user_def["name"], 
      :email => user_def["email"], 
      :password => user_def["password"], 
      :password_confirmation => user_def["password"])
    
    user_def['roles'].each do |role|
      u.add_role role.to_sym
    end
  end
end

# this might have broken
def populate_my_test_sale
  u = User.find_by_email("test@gmail.com")
  
  unless Rails.env == "production"
    u.addresses << FactoryGirl.create(:address)
    u.sales << FactoryGirl.create(:sale_with_1_book)
    s = u.sales.first
    s.calculate_discounts
    s.address_id = u.addresses.first.id
    
    bp = s.bitcoin_payments.first
    bp.user_id = u.id
    
    bp.save
    s.save
  end
  
  u.save
  
end

def deep_delete_user(user)
  # TODu: make this more pretty... but don't do dependent destroy on it all...
  BitcoinPayment.where(user_id: user.id).each { |x| x.delete }
  user.sale_ids.each {|id| CheckoutWallet.find_by_sale_id(id).delete}
  Sale.where(user_id: user.id).each { |x| x.delete }
  Address.where(user_id: user.id).each { |x| x.delete }
  
  user.delete
end



def populate_roles
  Role.delete_all
  
  #puts 'ROLES'
  YAML.load(ENV['ROLES']).each do |role|
    Role.find_or_create_by_name({ :name => role }, :without_protection => true)
    #puts 'role: ' << role  
  end
end

# This can't be performed in the initialization stage...
# I think it might rely on devise setting up the routes for users
# so I dropped a call to this function at the end of the routes file
def populate_users
  create_system_users if User.table_exists? and User.count == 0
end


##### Discounts!  TODu:  Move this to config/products.yml so it can be specified like other app specific things...
# and make it use an actual database
def populate_discounts
  Discount.delete_all
  
  bulk_discount = Discount.create(name: "Bulk Discount", discount_type: "percentage", active: true)
  bulk_discount.pricing_rules.create(case_value: "line_item.qty", condition: "1", discount_percent: "1.0 - 1.0")
  bulk_discount.pricing_rules.create(case_value: "line_item.qty", condition: "2..6", discount_percent: "1.0 - 0.95")
  bulk_discount.pricing_rules.create(case_value: "line_item.qty", condition: "7..100", discount_percent: "1.0 - 0.55")
  bulk_discount.pricing_rules.create(case_value: "line_item.qty", condition: "", discount_percent: "1.0 - 0.55")
  
  bitcoin_discount = Discount.create(name: "Bitcoin Discount", discount_type: "fixed_amount", active: true)
  bitcoin_discount.pricing_rules
    .create(case_value: "line_item.currency_used", condition: "\"BTC\"", discount_percent: "CostsOfBitcoin.usd_to_satoshi(2.00)")

  ninteynine_percent_off_sale_discount = Discount.create(name: "99% Off Sale", discount_type: "percentage", active: true)
  ninteynine_percent_off_sale_discount.pricing_rules
    .create(discount_percent: "1.0 - 0.01")
  # TODu:  above could be specified as nil case_value and condition... need to add code to discount application
  
  teacher_discount = Discount.create(name: "Teacher Discount", discount_type: "percentage", active: true)
  teacher_discount.pricing_rules.create(discount_percent: "1.0 - 0.6")
  
  wave_shipping_discount = Discount.create(name: "Wave Shipping Discount", discount_type: "modify_shipping", active: true)
  wave_shipping_discount.pricing_rules
    .create(discount_percent: "1.0")
  
end




##### Shipping Rules!  TODu:  Move this along with teh Discounts! stuff...
# This method hasn't been implemented yet due to no foriegn contacts/ interest yet
# bulk discounts should NOT be applied through this mechanism.  This is only for setting up the
# shipping cost baseline and it is based soly on the region being shipped to
def populate_shipping_plans
  ShippingPlan.delete_all
  
  #prod = Product.find_by_name("The Parade with the Drums")
  pwtd_shipping_plan = ShippingPlan.create(name: "Unimplemented Shipping Plan", shipping_base_amount: 3)
  
  pwtd_shipping_plan.pricing_rules.create(case_value: "sale.address.country", condition: "US", shipping_modifier: "shipping_base_amount * 1")
  pwtd_shipping_plan.pricing_rules.create(case_value: "sale.address.country", condition: "DE", shipping_modifier: "shipping_base_amount * 3")
end


def populate_discount_specifications
  prod = Product.find_by_sku("0001")
  
  # prod.discounts << Discount.find_by_name("99% Off Sale")
  prod.discounts << Discount.find_by_name("Bulk Discount")
  prod.discounts << Discount.find_by_name("Bitcoin Discount")
end


def populate_coupons
  Coupon.delete_all
  
  prod = Product.find_by_sku("0001")
  nnp_discount = Discount.find_by_name("99% Off Sale")
  wave_shipping = Discount.find_by_name("Wave Shipping Discount")

  c = nnp_discount.generate_coupon(:token => "occupy", 
    :product_id => prod.id, 
    :disabled_message => "This coupon was for beta testing and early birds.  It has since been disabled :( ")
  
  c = wave_shipping.generate_coupon(:usage_limit => 1)
end











def do_populate_database
  if Product.table_exists? and Product.count == 0
    populate_products 
    
    populate_retailers
    populate_roles
    
    populate_users   # you can't run this line until after routes are setup due to how devise works
  end
end
