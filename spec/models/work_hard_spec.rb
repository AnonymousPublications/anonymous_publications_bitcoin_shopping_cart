require 'spec_helper'


describe WorkHard do
  
  before :each do
    populate_products
  end

  it "Should have a valid link to a video explaining how to purchase via bitcoin"

  it "should have a valid link to a video explaining why bitcoin solves financial fraud"

  it "should have a complete spell check performed before going to production"

  it "Fix the bug in purchase controller where a discount LineItem is created even if there are no discounts available"

  it "should have unit tests testing the discount behavior"

  it "should be efficient, change the number of db requests needed per page display"

  it "should delete sales that are older than 7 days if they're unpaid" do
    make_random_assortment_of_sales
    
    # Make 3 of the unpaid sales date_created 3.weeks.ago
    #sales = Sale.where(receipt_confirmed: nil).limit(3)
    #sales.each do |sale|
    #  sale.created_at = 3.weeks.ago
    #  sale.save
    #end
    
    expect {
      # Run the function
      WorkHard.delete_old_sales
      
      # Test for the appropriate number of deletions
    }.to change(Sale, :count).by(-3)
    
  end
  
  it "get the mktg page populated"
  
  it "create a ShippingCostRules scaffold that allows the specification of shipping calculations and seed the DB"
  
  it "purchase/create should render a bitcoin 3d barcode for purchasing"
  
  
  
  
end


