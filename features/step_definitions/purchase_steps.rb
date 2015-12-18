

def ensure_debug_abilities
  $IsDebuggingUI = true
  $IsDebugApiOn = true
end

def create_buyer
  @address_data = { first_name: "Tedd", last_name: "Bundy", country: "United States",
               address1: "100 Hampton St", address2: "line2 of address",
               apt: "1", city: "Endover", state: "Fl", zip: 10101 }
  
  @buyer = { email: 'tedd@gmail.com', code_name: "my house", qty: 2 }.merge(@address_data)
end

def make_purchase
  delete_user
  visit '/purchases/new'
  
  fill_in "user_email", :with => @buyer[:email]
  fill_in "user_email_confirmation", :with => @buyer[:email]
  
  fill_in "Code Name",  with: @buyer[:code_name]
  fill_in "First Name", with: @buyer[:first_name]
  fill_in "Last Name",  with: @buyer[:last_name]
  fill_in "First Name", with: @buyer[:first_name]
  select @buyer[:country]
  fill_in "address_address1", with: @buyer[:address1]
  fill_in "address_address2", with: @buyer[:address2]
  fill_in "address_apt", with: @buyer[:apt]
  fill_in "address_city", with: @buyer[:city]
  select @buyer[:state]
  fill_in "address_zip", with: @buyer[:zip]
  fill_in "qty", with: @buyer[:qty]
  
  @price_js = find_by_id("book-cost").text.sub("~", "").strip
  
  click_button "Proceed to Bitcoin Payment"
  
  find_buyer
end

def collect_password
  @buyer[:password] = find_by_id("password").text.strip
end

def find_buyer
  @user ||= User.first conditions: {:email => @buyer[:email]}
end

def send_bitcoin_payment
  @user.sales.first.mock_completed_payment
end

def browse_as(buyer)
  visit "/users/sign_out"
  
  click_link "Login"
  fill_in "Email", with: buyer[:email]
  fill_in "Password", with: buyer[:password]
  click_button "Sign in"
end

def delete_all_sales_on_print_machine
  Sale.where("original_id is not NULL").delete_all
end

When(/^I fill out the purchase form$/) do
  create_buyer
  # visit the purchse page
  make_purchase
  
end

Then(/^I should see a complete sale purchase form$/) do
  sale = @user.sales.first
  # page should include a checkout wallet address
  expect(page).to have_content "Logout"
  
  expect(page).to have_content sale.checkout_wallet.input_address
  
  # and the unencrypted address values
  expect(page).to have_content @buyer[:address1]
  
  expect(page).to have_content sale.display_total_amount
  
  # should render the discounts properly...
  expect(page).to have_content sale.display_discount_amount
  
  collect_password
end

Then(/^I should have a new user$/) do
  expect(User.find_by_email(@buyer[:email])).not_to be nil
end

Then(/^I should have a new sale$/) do
  expect(Sale.count).to eq 1
end

Then(/^I should have a matching cost$/) do
  @price_rails = find_by_id("total-amount").text.strip
  expect(@price_js).to eq(@price_rails.to_s)
end

Then(/^my address should be decryptable by the development machines$/) do
  @sale = @user.sales.first
  @address = @sale.address
  
  expect(@address.first_name_cleartext).to eq @buyer[:first_name]
end




Then(/^the user should be able to see that they've made a bitcoin_payment$/) do
  #visit customer page
  click_link "Account Info"
  
  # see sale as unpaid
  expect(page).to have_content "pay"
  expect(page).to have_content "Purchase on"
  
  send_bitcoin_payment
  # visit customer page
  click_link "Account Info"
  
  # see sale as payment completed
  expect(page).not_to have_content "pay"
  expect(page).to have_content "Purchase on"
end

Then(/^the downloader should be able to notice their purchase$/) do
  ensure_debug_abilities
  click_link "Logout"
  
  click_button "Become Downloader"
  
  click_link "View Downloader Controls"
  
  expect(has_link?("DL paid purchase orders (x1)")).to be true
end

Then(/^the downloader should be able to download the purchase data$/) do
  @download_shippable_file_path = "/tmp/download_shippable_file.zip"

  nmd = Sale.build_shippable_file
  nmd.save_to_file @download_shippable_file_path
  
  nmd = NmDatafile.Load(@download_shippable_file_path, $FrontDoorKey)
  
  expect(nmd.sales.count).to eq 1      # should have 1 sale
  expect(nmd.line_items.count).to eq 1 # should have 1 line_items, 1 product
  expect(nmd.discounts.count).to eq 2
  expect(nmd.addresses.count).to eq 1  # should have 1 address
  expect(nmd.ready_for_shipment_batch).not_to be nil
end

Then(/^shipping should be able to upload the purchase data$/) do
  # the purchase orders must be uploaded using the controller... there's some benign overwriting that will take place, but not important for what we're testing
  
  click_button "Become Shipping"
  click_link "View Shipping Controls"

  expect(has_link?("(qty 2) Print orders ready for Shipment (x1)")).to be false # no shippable sales should be on the shipping system yet, since the upload didn't take place yet
  
  # upload the purchase orders recieved from downloader
  click_link "Upload purchase orders from a file"
  attach_file "file_upload_my_file", @download_shippable_file_path
  click_button "Upload"
  click_link "Shipping Control"
end

Then(/^shipping should be able to see shipping orders to print$/) do
  click_link "(qty 2) Print orders ready for Shipment (x1)"
  
  @address_data.reject{|k| k == :country}.each do |k, v|
    v = v.upcase if k == :state
    expect(page).to have_content v
  end
end

Then(/^shipping should be able to download the address completion file$/) do
  @address_completion_file_path = '/tmp/address_completion_file.zip'
  @expected_shipped_sales_count = 1
  
  # mock integration since files can't be requested...
  # without losing our login credentials
  nmd_ac = Address.build_address_completion_file
  nmd_ac.save_to_file @address_completion_file_path
  
  expect(nmd_ac.sales.count).to eq @expected_shipped_sales_count
end


Then(/^the downloader should be able to upload the address completion file$/) do
  delete_all_sales_on_print_machine
  
  visit "/admin_pages"
  click_button "Become Downloader"
  click_link "View Downloader Controls"
  click_link "Upload Confrimation of shipped POs from shipping team"
  attach_file "file_upload_my_file", @address_completion_file_path
  click_button "Upload"
  
  expect(page).to have_content "You just uploaded a confirmation file of shipped POs!"
end

Then(/^the sale should be marked as shipped$/) do
  @sale = @user.sales.where(original_id:nil).first
  expect(@sale.shipped).not_to be nil
end

Then(/^the user should be able to see that their sale has been shipped$/) do
  browse_as @buyer
  
  expect(find('#paid-0 td.shipped').text).to eq @sale.present_shipped    # User sees that there sale has indeed been shipped.  
  expect(find('#paid-0 td.edit-sale').text).to be_empty  # cannot edit ANY sale details after payment is confirmed and shipping has concluded, note: test for after prepped too...
end



