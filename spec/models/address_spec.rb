require 'spec_helper'

describe Address do
  before(:each) do
    @attr = {
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
  end

  it "should create a new instance given a valid attribute" do
    Address.create!(@attr)
  end
  
  # there's a test in the purchases requests too
  it "should be able to decrypt", current: true do
    a = FactoryGirl.create(:address)
    
    decryption = a.first_name_cleartext
    
    decryption.should eq "John\n"
  end
  
  
  it "should be able to create a valid address_completion_file" do
    
    # create some mock sales
    10.times do
      FactoryGirl.create(:sale_with_1_book)
    end
    3.times do
      FactoryGirl.create(:sale_with_2_books)
    end
    
    FactoryGirl.create(:sale_with_1_book_unpaid)
    
    simulate_completion_of_data_being_downloaded_and_sent_to_shipping
    
    mark_first_sales_address_erroneous
    
    Address.build_address_completion_file
    # create address completion file
    nmd_ac = Address.build_address_completion_file
    
    nmd_ac.erroneous_sales.count.should eq 1
    nmd_ac.sales.count.should eq 12
  end
  
end

def mark_first_sales_address_erroneous
  s = Sale.current_batch_that_was_shippable.first
  Address.find(s["address_id"]).update_attributes(erroneous: true)
end

def simulate_completion_of_data_being_downloaded_and_sent_to_shipping
  Sale.build_shippable_file
  Sale.all.each do |sale|
    sale.update_attributes(original_id: sale.id)
    sale.address.update_attributes(original_id: sale.address.id)
    sale.line_items.each do |li|
      li.update_attributes(original_id: li.id)
    end
  end
end
