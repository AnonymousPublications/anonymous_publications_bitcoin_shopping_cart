require 'spec_helper'

describe "ELITE shipping cycle tests" do
  include RequestHelpers
  
  before :each do
    populate_products
    @user = create_admin_user
    login @user
  end
  
  
  let(:valid_attributes) { { 
    "user_id" => @user.id,
    "address_id" => @user.addresses.first.id
  } }
  
  before :each do
    @downloadable_path = "/tmp/download_shippable.zip"
    @address_completion_file_path = "/tmp/address_completion_file.zip"
    
    @expected_sales_count = 5
    @expected_line_items_count = 5
    @expected_erroneous_sales_count = 3
    @expected_encryption_pair_count = 1
  end
  
  
  it "performs the initial download of PO data from the production machine", elite: "true", phase1: "true" do
    if ENV['is_print_cycle']
      
      phase1_algo
      
    end
  end
  
  it "performs the upload of PO data to the test server and responds properly", elite: "true", phase2: "true" do
    if ENV['is_print_cycle']
      
      expect{
        phase2_algo
      }.to change(Sale, :count).by(@expected_sales_count + 1) # add one for the spoofed sale
      
    end
  end
  
  it "performs the final upload of the address_completion data to the production machine via simulation", elite: "true", phase3: "true" do
    if ENV['is_print_cycle']
      # I think the best way to do a phase3, is to do phase1, and then generate_response_from_shipping_machine and
      # see that uploads into the database nicely...
      @address_completion_file = Tempfile.new('address_completion_file')
      @download_shippable_file = Tempfile.new('download_shippable_file')
      
      phase1_algo
      
      simulate_response_from_shipping
      
      # the response should be and address_completion_file with 2 
      phase3_algo
      
      # Upload address completion file
      # input:  address_completion.zip
      # test:  Marks the sales as Downloaded and shipped
      # test:  unmarks the sales as prepped
      # test:  flags the erroneous addresses as erroneous so they show up to the end user as messed up
    end
  end
  
  def simulate_response_from_shipping(n_shipped = 2)
    nmd = NmDatafile::Load(@downloadable_path, $FrontDoorKey)
    
    nmd_address_completion = nmd.simulate_address_completion_response(n_shipped)
    
    nmd_address_completion.save_to_file @address_completion_file.path
  end
  
  def generate_valid_address_errors_params
    addresses = {}
    
    Sale.current_batch_that_was_shippable.each.with_index do |sale, i|
      sale = Sale.find(sale["id"])
      if i <= 2
        addresses[sale.address.id.to_s] = { "id" => "#{sale.address.id}", "erroneous" =>"on" }
      else
        addresses[sale.address.id.to_s] = { "id" => "#{sale.address.id}" }
      end
    end

    return { "address" => addresses }
  end
  
  def phase1_algo
    # generate 10 sales that are reciept_confirmed, but 5 have been shipped already
    10.times do
      FactoryGirl.create(:user_with_1_book)
    end
    
    Sale.all.each.with_index do |s, i|
      if i >= 5
        s.shipped = Time.now 
        s.save
      end
    end
    
    
    
    # make ten dorky sales that aren't ready for anything
    10.times { FactoryGirl.create(:user_with_1_book_unpaid) }
    
    # navigate to the download page... must be authenticated as admin user...
    get "admin_pages/download_shippable"
    File.binwrite(@downloadable_path, response.body)
    nmd = NmDatafile::Load(@downloadable_path, $FrontDoorKey)
    
    # test:  The zip contains the correct number of sales
    @expected_address_count = @expected_sales_count
    nmd.sales.count.should eq @expected_sales_count
    nmd.line_items.count.should eq @expected_line_items_count
    nmd.addresses.count.should eq @expected_address_count
    nmd.encryption_pairs.count.should eq @expected_encryption_pair_count
    
    # test: marks them as prepped
    Sale.where("shipped is NULL AND prepped = ?", true).count.should eq @expected_sales_count
    
    # test:  subsequent downloades of download_shippable will be the same file, and have the same effects
    get "admin_pages/download_shippable"
    File.binwrite(@downloadable_path, response.body) # Saves the zip data for phase 2 and 3
    nmd = NmDatafile::Load(@downloadable_path, $FrontDoorKey)
    
    nmd.sales.count.should eq @expected_sales_count
    nmd.line_items.count.should eq @expected_line_items_count
    nmd.addresses.count.should eq @expected_address_count
    
    # output:  download_shippable.zip is now available in the /tmp folder
  end
  
  def phase2_algo
    
    @retailer_address_count = Address.count
    
    id_of_conflicting_address = create_some_bogus_benign_database_entries
    hack_the_upload_shippable_params_file_to_conflict_with(id_of_conflicting_address)
    @spoofed_sale = Sale.first
    
    nmd_shippable_file = NmDatafile::Load(@downloadable_path, $FrontDoorKey)
    up = nmd_shippable_file.generate_upload_params
    post '/admin_pages/upload_shippable', up
    
    # there should now be a sale associated with id_of_conflicting_address, unless our algorithm for preventing this works perfectly :)
    Sale.find_by_address_id(@expectedly_unassociated_address_id).should be_nil
    
    LineItem.count.should eq @expected_line_items_count + 1  # add one to account for spoofing
    
    # Addresses.count.should be_greater_than
    Address.count.should be_within(Sale.count*100).of(1)  # this is HARDLY a test of anything due to how the fixtures are randomized... btw, I've never seen that ANYWHERE, but lol its interesting
    
    EncryptionPair.count.should eq 2 # Should have 1 from the import, and one when we make that guber sale on the shipping machine
    
    # test address_labels will print properly
    get "/admin_pages/address_labels?qty=1"
    assigns(:addresses).count.should eq @expected_sales_count
    
    # test sales can be marked erroneous
    post "/address_errors", generate_valid_address_errors_params
    Address.where(:erroneous => true).count.should eq @expected_erroneous_sales_count
    
    # Can download the damned confirmation zip file
    get "/admin_pages/address_completion_file"
    
    # write out the address completion file to the tmp dir
    File.binwrite(@address_completion_file_path, response.body)
    
    nmd = NmDatafile::Load(@address_completion_file_path, $FrontDoorKey)
    nmd.erroneous_sales.count.should eq @expected_erroneous_sales_count
    nmd.sales.count.should eq(@expected_sales_count - @expected_erroneous_sales_count)
    
    
    # double check that the addresses shown on the label print page are reduced by the amount of erroneous addresses marked off
    get "/admin_pages/address_labels?qty=1"
    assigns(:addresses).count.should eq @expected_sales_count - @expected_erroneous_sales_count
    
    # we shouldn't have a sale that has 2 line_items due to the fact that our
    # reassociate_with_adjusted_ids_for! method didn't work for LineItems
    @spoofed_sale.line_items.count.should eq 1 
    
    # input:  download_shippable.zip
    # test:  generates the proper number of addresses on the view?
    # test:  Allows marking addresses as erroneous
    # output: address_completion.zip
  end
  
  def phase3_algo
    # Upload address_completion_file.zip
    
    initial_count_of_prepped = Sale.where(:prepped => true).count
    initial_count_of_shipped = Sale.marked_shipped.count
    initial_count_of_erroneous = Address.where(:erroneous => true).count
    
    nmd_address_completion = NmDatafile::Load(@address_completion_file_path, $FrontDoorKey)
    up = nmd_address_completion.generate_upload_params
    
    nmd_address_completion.simulate_rfsb_existance_on_webserver
    
    
    post '/admin_pages/upload_shipped', up
    
    final_count_of_prepped = Sale.where(:prepped => true).count
    final_count_of_shipped = Sale.marked_shipped.count
    final_count_of_erroneous = Address.where(:erroneous => true).count
    
    # test:   Sales are unmarked prepped
    final_count_of_prepped.should eq(0)                                                              # initial_count_of_prepped - @expected_sales_count
    # test:   Sales are marked shipped
    final_count_of_shipped.should eq(initial_count_of_shipped + @expected_sales_count - @expected_erroneous_sales_count) # 7
    # test:   erroneous sales are marked with errors
    final_count_of_erroneous.should eq(@expected_erroneous_sales_count + initial_count_of_erroneous) # 3
    
    
    # test:   DL shippable will yeiled ZERO new stuff because there's nothing but erroneous POs with confirmed receipts that aren't shipped
    # Candidate for DRY refactoring
    get "admin_pages/download_shippable"
    File.binwrite(@download_shippable_file.path, response.body)
    nmd = NmDatafile::Load(@download_shippable_file.path, $FrontDoorKey)
    
    # test:  The zip contains the correct number of sales
    nmd.sales.count.should eq 0
    
    # test:   Sales will have their checkout_wallet_ids still, they can be stripped if we import them wrong
    # find a sale that was processed, and check that it's checkout_wallet hasn't been set to nil
    @shipped_sale = Sale.where("shipped is not NULL").first
    @shipped_sale.checkout_wallet.should_not be_nil
    
    # input:  address_completion_file.zip
    # test:   Sales are marked shipped
    # test:   Sales are marked downloaded and unmarked prepped
    # test:   erroneous sales are marked with errors
    # test:   DL shippable will yeiled ZERO new stuff because there's nothing but erroneous POs with confirmed receipts that aren't shipped
  end
  
  def reinitialize_database_for_phase_3
    # 1)  ignore the prepped`age of Sales, since phase2 doesn't modify that field
    # 2)  Ignore the shipped`age of Sale since phase2 has no bearing on shipped
    # 3)  Unset the erroneousness of all sales since that field is modified...
    erroneous_addressess = Address.where(:erroneous => true)
    erroneous_addressess.each do |address|
      address.erroneous = false
      address.save
    end
  end
  
  # This helps us test the effecicy of Importable#reassociate_with_adjusted_ids_for!
  def create_some_bogus_benign_database_entries
    s = FactoryGirl.create(:sale_with_1_book_unpaid)
    line_item = s.line_items.first
    line_item.update_attributes(qty: 90)
    # FactoryGirl.create(:line_item)
    FactoryGirl.create(:address)
    
    @expectedly_unassociated_address_id = Address.last.id
    
    @spoof_address_count = Address.count - @retailer_address_count
    
    Sale.find_by_address_id(@expectedly_unassociated_address_id).should be_nil
    @expectedly_unassociated_address_id
  end
  
  def hack_the_upload_shippable_params_file_to_conflict_with(id_of_conflicting_address)
    nmd_file = NmDatafile::Load(@downloadable_path, $FrontDoorKey)
    
    sale_to_change = nmd_file.sales.first
    address_to_change = get_address_to_change(nmd_file.addresses, sale_to_change)
    sale_to_change["address_id"] = id_of_conflicting_address
    address_to_change["id"] = id_of_conflicting_address
    address_to_change["original_id"] = id_of_conflicting_address
    
    nmd_file.save_to_file(@downloadable_path)
  end
  
  # TODu: move into nm_datafile, hint, import hashes that extend LikeActiveRecordButDifferent so they have Sale#address functionality
  def get_address_to_change(addresses, sale)
    addresses.each do |address|
      return address if address["id"] == sale["address_id"]
    end
    raise "couldn't find the address associated with the sale"
  end
  
end