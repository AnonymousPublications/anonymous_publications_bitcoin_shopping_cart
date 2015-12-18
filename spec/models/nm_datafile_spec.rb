=begin
require 'spec_helper'

describe 'NmDatafile' do
  
  before :each do
    populate_products
  end

  # TODO:  Set this test to be skipped, most has been moved to nm_datafile gem!
  # First verify test for:  Sale.build_shippable_file,  ReadyForShipmentBatch.last
  it "can be loaded with data arrays and then return them" do
    
    2.times {FactoryGirl.create(:sale_with_1_book)}
    
    nmd_binary_string = Sale.build_shippable_file.save_to_string
    
    rfsb1 = ReadyForShipmentBatch.last
    
    nmd_file = NmDatafile::LoadBinaryData nmd_binary_string
    
    
    sales = nmd_file.sales
    line_items = nmd_file.line_items
    discounts = nmd_file.discounts
    addresses = nmd_file.addresses
    ubws = nmd_file.ubws
    encryption_pairs = nmd_file.encryption_pairs
    rfsb = nmd_file.ready_for_shipment_batch
    
    nm_data = NmDatafile.new(:shippable_file, sales, line_items, discounts, addresses, ubws, encryption_pairs, rfsb)
    
    nm_data.sales.count.should eq 2
    nm_data.ready_for_shipment_batch["batch_stamp"].should eq rfsb1.batch_stamp

  end
  
  # TODO: delete ok, have something in gem
  it "should be able to render a zip file that contains the same data as the old way" do
    2.times {FactoryGirl.create(:sale_with_1_book)}
    
    nmd_file = Sale.build_shippable_file
    
    sales = nmd_file.sales
    line_items = nmd_file.line_items
    discounts = nmd_file.discounts
    addresses = nmd_file.addresses
    ubws = nmd_file.ubws
    encryption_pairs = nmd_file.encryption_pairs
    rfsb = nmd_file.ready_for_shipment_batch
    
    nm_data2 = NmDatafile.new(:shippable_file, sales, line_items, discounts, addresses, ubws, encryption_pairs, rfsb)
    nm_data2.should eq nmd_file
  end
  
  # TODO: delete ok, have something in gem
  it "should be able to read a zip file that was made via the old way" do
    2.times {FactoryGirl.create(:sale_with_1_book)}
    
    nmd = Sale.build_shippable_file
    
    shippable_file = Tempfile.new("shippable_file")
    nmd.save_to_file shippable_file.path
    
    nmd_loaded = NmDatafile::Load shippable_file.path
    
    nmd.should eq nmd_loaded
  end
  
  
  it "should be able to generate a proper address_completion_file" do
    nm_data = NmDatafile.new(:address_completion_file)
    
    nm_data.create_sales 5, 1
    
    nm_data.sales.count.should eq 5
    nm_data.erroneous_sales.count.should eq 1
  end
  
  
  it "should be able to create 5 sales for shippable_file" do
    nm_data = NmDatafile.new(:shippable_file)
    
    nm_data.create_sales 5
    
    nm_data.sales.count.should eq 5
  end
  
  it "has all the attributes implemented" do
    2.times {FactoryGirl.create(:sale_with_1_book)}
    
    nmd = Sale.build_shippable_file
    
    shippable_file = Tempfile.new("shippable_file")
    nmd.save_to_file shippable_file.path
    
    nmd_loaded = NmDatafile::Load shippable_file.path
    
    nmd_loaded.file_type.should eq :shippable_file
  end
  
  
end

=end