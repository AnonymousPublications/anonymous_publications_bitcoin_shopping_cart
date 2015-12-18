# This file is for testing import and export scenarios
#
#
# Scenarios:
# 
# skipped address completion file
#   1) Shipper imports a batch, 
#   2) Shipper forgets to generate an address_completion_file
#   3) Shipper imports a second batch (it will likely contain B1 data so won't matter)
#   Bug result:
#     The first batch would be marked shipped even though the address_completion_file was never generated
#   Resolution result:
#     (sales from B1 should not be marked shipped yet.  The webserver should yell too?)
# 
# lost address completion file
#   1) Shipper imports a batch (B1),
#   2) Shipper generates the B1 address_completion_file
#   3) Shipper imports a second batch (B2)
#   4) Shipper loses the B1 address_completion_file
#   5) Shipper generates the B2 address_completion_file
#   6) Shipper upload the B2 ACF
#   Self Repair Result: 
#     All the sales from the B1 would also be in B2, so the data from the lost address_completion_file would 
#     possibly be included in the B2 ACF... but then again maybe not... this really is complex...
# 
# 
# 
# This shit is so complicated, i'm putting it on the TODu list till I start running into the actual bugs.  I think
# the first two scenarios I listed off actually resolve themselves already, so it's not such an issue.  
# 
# 

require 'spec_helper'

describe 'AdminPagesController' do
  #login_admin
  #create_products
  
  describe "POST upload_shippable_file" do
    before :each do
      # Generate some sales to symbolize the current batch
      # @download_shippable_file = conjure_valid_download_shippable_file
      config = {file_type: :shippable_file, symmetric_key: $FrontDoorKey}
      @nmd_shippable_file = NmDatafile.new(config)
      @nmd_shippable_file.create_sales 5
      
      populate_products
      @user = create_admin_user
      login @user
    end
    
    it "it allows initial upload" do
      ReadyForShipmentBatch.count.should eq 0
      
      #upo = generate_upload_params(@download_shippable_file.path, "upload_shippable_file")
      up = @nmd_shippable_file.generate_upload_params
      
      post '/admin_pages/upload_shippable', up
    end
    
    it "marks selected sales as shipped" do
      # Generate some sales to symbolize an old batch sitting on the shipping machine
      generate_a_batch_of_sales_presumed_shipped 5
      
      up = @nmd_shippable_file.generate_upload_params
      
      post '/admin_pages/upload_shippable', up
      
      Sale.get_shippable.count.should eq 5
      
    end
    
    it "doesn't mark erroneous sales as shipped" do
      # Generate some sales for the last batch
      generate_a_batch_of_sales_presumed_shipped 5, 1
      
      up = @nmd_shippable_file.generate_upload_params
      
      post '/admin_pages/upload_shippable', up
      
      Sale.get_shippable.count.should eq 5
      Sale.marked_shipped.count.should eq 4 # marked shipped
    end
    
    # Instead of desperately trying to re-build this test, maybe I should come up with a better system...
    # I'm essentially conducting an integration test on scenerios... I think this is... a difficult approach
    # Whereas with cucumber
    # TODu:  this test... just... fixed itself... wtf...
    # Hmmm.... I'm noticing inconsistent results with this test, it's definately fucked up
    # where the nmd methods are used to create sales... I bet that's got somefin to do with it
    it "updates the batch_id of erroneous files if they were erroneous and come in as a new batch", current: true do
      
      # Batch1
      # Simulate 5 shippable sales and 1 erroneous on the shipping machine (ignore production webserver)
      generate_a_batch_of_sales_presumed_shipped 5, 1    # creates 5
      
      # Find the erroneous sale
      erroneous_sale = Sale.erroneous_sales.first
      erroneous_sale.address.update_attributes(erroneous: false)
      
      config = {file_type: :shippable_file, symmetric_key: $FrontDoorKey}
      nmd_shippable_file = NmDatafile.new(config)
      nmd_shippable_file.create_sales 4
      nmd_shippable_file.add_sale erroneous_sale
      
      # Upload a brand new batch of shippable sales to the shipping machine that includes an erroneous from a previous batch
      up = nmd_shippable_file.generate_upload_params
      
      post '/admin_pages/upload_shippable', up  # should add 4-5 new sales
      
      Sale.marked_shipped.count.should eq 5
      erroneous_sale.reload
      erroneous_sale.shipped?.should be true   # The erroneous sale isn't being marked shipped... sometimes
    end
    
    # if they come in as a new batch, but they WERE in an older batch... their batch_id should NOT be updated, it should
    # simply be marked shipped... because they were shipped
    it "Shipping: duplicates that come in as a second batch will show up as already shipped, and not of a new batch..." do
      # Perspective:  Shipping Machine
      
      # FIRST BATCH FILE
      # I need to generate an upload_shippable file consisting of 5 sales
      # and I need to upload it to shipping machine
      config = {file_type: :shippable_file, symmetric_key: $FrontDoorKey}
      nmd_shippable_file = NmDatafile.new(config)
      nmd_shippable_file.create_sales 5
      
      batch_stamp1 = nmd_shippable_file.ready_for_shipment_batch.batch_stamp
      up1 = nmd_shippable_file.generate_upload_params
      first_five_sales = nmd_shippable_file.sales.dup
      
      # SECOND BATCH FILE
      # Now that I have the upload_shippable file, I need to add one more sale to the mix and create
      # a second ready_for_shipment file which will be uploaded after the first one is so tests can be done
      # add a new sale to the file, this will regenerate a new batch_id
      new_sale = FactoryGirl.create(:sale_with_1_book)
      nmd_shippable_file.add_sale(new_sale)
      new_sale.delete
      
      batch_stamp2 = nmd_shippable_file.ready_for_shipment_batch.batch_stamp
      up2 = nmd_shippable_file.generate_upload_params
      
      post '/admin_pages/upload_shippable', up1
      post '/admin_pages/upload_shippable', up2
      
      ReadyForShipmentBatch.count.should eq 2
      
      # test that the sale's batch_id hasn't been changed on the old 5
      first_five_on_shipping = []
      first_five_sales.each do |sale|
        first_five_on_shipping << Sale.find_by_original_id(sale.id)
      end
      
      first_five_on_shipping.each do |sale_on_shipping|
        # the first five should have the same batch_stamp as they had when they originally came in...
        sale_on_shipping.ready_for_shipment_batch.batch_stamp.should eq batch_stamp1
        sale_on_shipping.shipped.should be_truthy
      end
      
      # TODu:  test that when the production webserver receives the address_completion_file, the rsfb on those files gets set back
      # to what batch it was originally shipped as...  This isn't important at all
      # This test is complete, the assumption is that the downloader DLed the downloadable file accidentally, before he/she upped 
      # the address completion file...
    end
    
    # TODu
    it "should alert the shipper if they import the same batch twice" do
      # 1) the system needs to check the rfsb to see if it's been uploaded before
      # 2) The system needs to check the nmd#file_hash to see if the data uploaded before is the same...
      
      @virtual_shipping_system = VirtualSystem.new(:shipping)
      @virtual_webserver_system = VirtualSystem.new(:webserver)
      
      @virtual_webserver_system.create_sales(5)
      sf1 = @virtual_webserver_system.export_sf # shippable_file
      
      up = @virtual_shipping_system.import_sf!(sf1)
      
      post '/admin_pages/upload_shippable', up
      (response.body =~ /Upload Complete!/).should_not be_nil
      
      post '/admin_pages/upload_shippable', up
      (response.body =~ /You already uploaded this shippable file on/).should_not be_nil

      
      
      #acf1 = @virtual_shipping_system.export_acf(4, 1)   # address_completion_file
      
      #up = @virtual_webserver_system.import_acf!(acf1)
      #post '/admin_pages/upload_shipped', up
      
    end
    
    it "should alert the downloader if they import the same address_completion_file twice", current: true do
      # build sales on webserver
      # generate nmd file
      # simulate address_completion
      # upload it twice
      
      5.times { FactoryGirl.create(:sale_with_1_book) }
      
      nmd = Sale.build_shippable_file
      
      acf_nmd = nmd.simulate_address_completion_response(5)
      
      params = acf_nmd.generate_upload_params
      
      post '/admin_pages/upload_shipped', params
      (response.body =~ /You just uploaded a confirmation file of shipped POs\!/).should_not be_nil
      
      post '/admin_pages/upload_shipped', params
      (response.body =~ /You already uploaded this address_completion_file on/).should_not be_nil
    end
    
    it "webserver:  It shouldn't matter if the shipper forgets to build an address completion file since new batches just get merged into the current batch" do
      # create batch1
      # upload it to shipping
      # add a new sale to batch1... since... we can't really create a fresh batch on the webserver until an ACF is upped
      # upload batch2 which is just batch1 plus extra file
      # create an ACF
      # up the ACF
      # test if all the sales get marked as shipped... they probably do...
      # thus no need to warn the shipped they didn't create an ACF
      
      s1 = FactoryGirl.create(:sale_with_1_book)
      
      sf1 = Sale.build_shippable_file
      
      
      post '/admin_pages/upload_shippable', sf1.generate_upload_params
      
      s2 = FactoryGirl.create(:sale_with_1_book)
      
      sf1point5 = Sale.build_shippable_file
      
      post '/admin_pages/upload_shippable', sf1point5.generate_upload_params
      
      acf1 = Address.build_address_completion_file
      
      Sale.delete_shipping_machine_sales!
      
      post '/admin_pages/upload_shipped', acf1.generate_upload_params
      
      # test all sales marked shipped
      s1.reload
      s2.reload
      
      Sale.count.should eq 2
      
      s1.shipped?.should be true
      s2.shipped?.should be true
    end
    
    it "Webserver: should behave properly in second generation of transfers especially regarding errors" do
      s1, sf1 = create_sales_on_webserver_and_sf
      
      upload_sf sf1
      
      e1 = mark_errors_on_shipping_machine(s1.first)
      
      acf1 = create_acf
      
      import_acf_to_webserver acf1

      correct_error e1

      s2, sf2 = create_sales_on_webserver_and_sf
      
      upload_sf sf2   
      e1.reload
      
      test_sales_show_up_on_printout e1
      
      test_matching_batch_id(e1, ReadyForShipmentBatch.last)
      
      acf2 = create_acf
      
      import_acf_to_webserver acf2
      
      test_corrected_erroneous_sale_was_marked_shipped e1
      test_number_of_sales_marked_shipped_proper 10
    end
    
  end
end



def create_sales_on_webserver_and_sf
  s1 = []
  
  5.times do
    s1 << FactoryGirl.create(:sale_with_1_book)
  end
  
  [s1, Sale.build_shippable_file]
end

def upload_sf(sf)
  post '/admin_pages/upload_shippable', sf.generate_upload_params
end

def mark_errors_on_shipping_machine(sale)
  s = find_sale_on_shipping_given_webserver_sale(sale)
  s.address.update_attributes(erroneous: true)
  s
end

def find_sale_on_shipping_given_webserver_sale(sale)
  Sale.find_by_original_id(sale.id)
end

def find_sale_on_webserver_given_shipping_sale(sale)
  Sale.find(sale.original_id)
end

def create_acf
  Address.build_address_completion_file
end

def import_acf_to_webserver(acf)
  post '/admin_pages/upload_shipped', acf.generate_upload_params
end

def correct_error(sale)
  s = find_sale_on_webserver_given_shipping_sale(sale)
  s.address = FactoryGirl.create(:address)
  s.save
end

def create_sf
  Sale.build_shippable_file
end

def test_sales_show_up_on_printout(e1)
  s = Sale.get_shippable.find(e1.id)
  
  s.should_not be_nil
end

def test_corrected_erroneous_sale_was_marked_shipped(e1)
  s = find_sale_on_webserver_given_shipping_sale(e1)
  
  s.shipped?.should be true
end

def test_number_of_sales_marked_shipped_proper(n_sales_shipped)
  sales = Sale.where('shipped is not NULL')
  sales.count.should eq n_sales_shipped
end

def test_matching_batch_id(sale, rfsb)
  sale.ready_for_shipment_batch_id.should eq rfsb.id
end




def import_sf
  post :upload_shippable_file, up
end
  
def generate_a_batch_of_sales_presumed_awaiting_download(shipped_count = 5, erroneous_count = 0)
  #create_sales_on_shipping_awaiting_address_completion_phase 
  sales = []
  shipped_count.times { sales << FactoryGirl.create(:sale_with_1_book) }
  #rfsb = ReadyForShipmentBatch.create(batch_stamp: ReadyForShipmentBatch.calculate_ready_for_shipment_hash)
  #sales.each do |sale|
    #sale.ready_for_shipment_batch = rfsb
    #sale.save
  #end
  
  erroneous_count.times { |i| sales[i].address.update_attributes(erroneous: true) }
  sales
end

def generate_a_batch_of_sales_presumed_shipped(shipped_count = 5, erroneous_count = 0)
  sales = []
  shipped_count.times { sales << FactoryGirl.create(:sale_with_1_book) }
  
  rfsb = ReadyForShipmentBatch.gen

  sales.each do |sale|
    sale.ready_for_shipment_batch = rfsb
    sale.original_id = sale.id
    sale.save
  end
  
  erroneous_count.times { |i| sales[i].address.update_attributes(erroneous: true) }
  sales
end

# erroneous_sale: if an ActiveRecord sale object is given as erroneous_sale, this method
# will use that sale as one of the shippable sales instead of generating a brand new one.  
# Used for testing second attempt of erroneous address shipping.
# TODu: this code doesn't exactly do what's expected but fuck it
def conjure_valid_download_shippable_file(sale_count = 5, erroneous_sale = nil)
  new_sales_to_make_count = sale_count
  new_sales_to_make_count = sale_count - 1 unless erroneous_sale.nil?
  # sales << erroneous_sale unless erroneous_sale.nil?
  sales = generate_a_batch_of_sales_presumed_shipped new_sales_to_make_count
  
  
  # query the system for the download shippable file
  zip_data = Sale.build_shippable_file.save_to_string
  
  # delete sales... deeply...  can we do a rollback in rails?
  Sale.deep_delete_sales(sales)
  
  # return the Tempfile object
  download_shippable_file = Tempfile.new('download_shippable_file')
  File.write(download_shippable_file.path, zip_data)
  
  download_shippable_file
end

def generate_address_shippable_that_contains_a_previously_erroneous_sale(erroneous_sale)
  conjure_valid_download_shippable_file(5, erroneous_sale)
end











