# Also see requests/purchases_spec.rb 

require 'spec_helper'

describe "Sales" do
  include RequestHelpers
  
  before :each do
    populate_products
    @user = FactoryGirl.create(:user)
    login @user
  end
  
  
  describe "For existing sales" do
    
    it "should prevent users from deleting other people's sales" do
      user2 = FactoryGirl.create(:user_with_1_book)
      other_sale = user2.sales.first
      delete '/sales/' + other_sale.id.to_s
    end
    
    describe "the User's Sale#show page" do
      
      it "should show the cost of the book" do
        sale = create_sale_for_user(@user)
        get "/sales/#{@user.sales.first.to_param}"
        desired_text = "<span class='money'>#{WorkHard.display_satoshi_as_btc(sale.remainder_to_pay)}</span>\n<span>BTC</span>"
        (response.body =~ /#{desired_text}/).should_not be_nil
      end
      
      it "should show the remainder to pay if a partial payment was tendered" do
        sale = create_sale_for_user(@user)
        sale.bitcoin_payments.create(:value => 10000)
        sale.save
        
        get "/sales/#{@user.sales.first.to_param}"
        desired_text = "<span class='money'>#{WorkHard.display_satoshi_as_btc(sale.remainder_to_pay)}</span>\n<span>BTC</span>\nstill left to pay..."
        (response.body =~ /#{desired_text}/).should_not be_nil
      end
  
    end
  end
end