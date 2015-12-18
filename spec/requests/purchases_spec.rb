require 'spec_helper'

describe "Purchases" do
  before :each do
    populate_products
    
    @primary_address = {
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
    
    @secondary_address_params = {
        "code_name"=>"My Second House",
        "first_name"=>"Phill",
        "last_name"=>"Mill",
        "country"=>"United States",
        "address1"=>"123 Feather",
        "apt"=>"1",
        "city"=>"D",
        "state"=>"AL",
        "zip"=>"00001"
      }
    
    @wisc_address = {
        "code_name" => "My First House",
        "first_name" => "Phill",
        "last_name" => "Mill",
        "country" => "United States",
        "address1" => "123 Feather",
        "apt" => "1",
        "city" => "D",
        "state" => "WI",
        "zip" => "00001"
      }
    
    @purchase_params = { 
      "line_items"=>{"0"=>{"product_sku"=>"0001", "price_spoof"=>"0.02"}},
      "products"=>{"0"=>{"shipping_price_spoof"=>"0.002", "sku"=>"0001"}},
      "user"=>{"email"=>"a@z.com", "email_confirmation"=>"a@z.com"},
      "address"=> @primary_address,
      "line_item"=>{"qty"=>"1", "discount_verification_instructions"=>""},
      "submit"=>"Proceed to Bitcoin Payment",
      "controller"=>"purchases",
      "action"=>"create"
    }
    
    
    @line_item_params = {
        id: "1",
        qty: "1"
      }
    
    CostsOfBitcoin.reset_temp_data # allows the system to make moch calls to APIs
  end
  
  it "workaround for weird bug I introduced at some point where the first test relations will fail", current: true do
      
  end
  
  describe "GET /Purchases/new" do
    it "works!" do
      get '/purchases/new'
      response.status.should be(200)
    end
  end
  
  describe "POST /Purchases" do
    it "can create new posts" do
      post '/purchases', @purchase_params
      response.status.should be(302)
      (response.body =~ /There were problems with the following/).should eq nil
      
      Sale.count.should eq 1
      User.count.should eq 1
      LineItem.count.should eq 1 + 1 # one discount lines and one product line
      Address.count.should eq 1
      CheckoutWallet.count.should eq 1
      CheckoutWallet.first.destination_address.should eq ENV['SHOPPING_CART_WALLET']
    end
    
    it "can tax sales appropriately" do
      post '/purchases', @purchase_params.merge("address" => @wisc_address)
      response.status.should be(302)
      
      Sale.first.tax_amount.should eq 160000
    end
    
    it "should apply a bulk shipping discount to an order of 3" do
      post '/purchases', @purchase_params.merge("line_item"=> {"qty"=> "3", "discount_verification_instructions"=>""})
      sale = Sale.last
      
      # Bulk discount
      bulk_discount_line_item = sale.line_items.first.discounts.find_by_description("Bulk Discount")
      bulk_discount_line_item.price.should_not eq 0.0
      
      # Bitcoin discounts
      bitcoin_discount_line_item = sale.line_items.first.discounts.find_by_description("Bitcoin Discount")
      bitcoin_discount_line_item.price.should_not eq 0.0
    end
    
    it "should prevent a line_item's value from going below zero" do
      post '/purchases', @purchase_params.merge("line_item"=> {"qty"=> "3", "discount_verification_instructions"=>""})
      sale = Sale.last
      
      crazy_discount = Discount.create(name: "Crazy Discount", discount_type: "percentage")
      crazy_discount.pricing_rules.create(discount_percent: "1.0 - 0.03")
      crazy_coupon = crazy_discount.generate_coupon(product_id: sale.line_items.first.product.id)
      crazy_coupon.apply_to! sale
      
      sale.line_items.first.discounts.count.should eq 4
      
      
      li = sale.line_items.first
      discounts = li.discounts
      
      value_of_line_item = li.price_extend
      value_of_discounts_total = discounts.sum(&:price_extend) * -1
      
      
      (value_of_line_item >= value_of_discounts_total).should be true
    end
    
    it "should prevent a sale from being valued at less than the minimum" do
      post '/purchases', @purchase_params.merge("line_item"=> {"qty"=> "3", "discount_verification_instructions"=>""})
      sale = Sale.last
      
      # wave shipping discount
      c = Discount.find_by_name("Wave Shipping Discount").generate_coupon
      c.apply_to! sale
      li = sale.line_items.first
      li.update_attributes(:price => 0)
      li.calculate_fields!
      
      sale.total_amount.should eq 50000
      
      get "/sales/#{sale.id}"
      
      (response.body =~ /Minimum Sale Amount Adjustment/).should_not eq nil
    end
    
    it "should apply the exact amount of discount" do
      post '/purchases', @purchase_params.merge("line_item"=> {"qty"=> "3", "discount_verification_instructions"=>""})
      sale = Sale.last
      li_price = sale.line_items.first.price
      # li_qty = 3
      
      sale.total_amount.should eq 7900000
    end
    
    it "should have a working 99% off sale capabale system" do
      p = Product.find_by_sku("0001")
      p.discounts << Discount.find_by_name("99% Off Sale")
      
      post '/purchases', @purchase_params.merge("line_item"=> {"qty"=> "3", "discount_verification_instructions"=>""})
      sale = Sale.last
    end
    
    # If the user is logged in and they make a purchase...
    #   it should just work, the form will just have less fields on the view...   
    #     But 
    it "shows error page for previously registered email when not logged in" do
      post '/purchases', @purchase_params
      response.status.should be(302)
      
      logout
      
      post '/purchases', @purchase_params
      response.status.should be(200)
      (response.body =~ /There were problems with the following/).should_not eq nil
    end
    
    it "shows error page for missing qty" do
      @purchase_params["line_item"]["qty"] = 0
      post '/purchases', @purchase_params
      response.status.should be(200)
      (response.body =~ /There were problems with the following/).should_not eq nil
    end
    
    
    
    it "shows error page for missing address field" do
      @purchase_params["address"]["city"] = ''
      post '/purchases', @purchase_params
      response.status.should be(200)
      (response.body =~ /There were problems with the following/).should_not eq nil
    end
    
    
    it "calculates the correct values for shipping cost", current: true do
      post '/purchases', @purchase_params
      s = Sale.first
      
      s.line_items.first.shipping_cost_usd.should eq 3.0
      s.line_items.first.shipping_cost_btc.should eq 490000
      
      s.shipping_amount.should eq 490000
      
      response.status.should be(302)
    end
    
    it "can wave shipping with the right coupon application" do
      post '/purchases', @purchase_params
      s = Sale.first
      wave_shipping = Discount.find_by_name("Wave Shipping Discount")
      coupon = wave_shipping.generate_coupon(:usage_limit => 1)
      
      coupon.apply_to!(s)
      
      # apply coupon to sale
      s.shipping_amount.should eq 0.0
    end
    
    # not sure what to do here...  I think the app should signal us when this happens
    it "shows error page blockchain.info is down" #do
      #post '/purchases', @purchase_params
      #response.status.should be(200)
      #(response.body =~ /There were problems with the following/).should_not eq nil
    #end
    
    describe "for already logged in users with a purchase" do
      before :each do
        post '/purchases', @purchase_params  # create a valid purchase and thus be automatically logged in
        @user = User.last
        @sale = @user.sales.last
        
        @sale_params = {
          address_id: @sale.address.id.to_s
        }
        
        # create secondary address
        @secondary_address = FactoryGirl.create(:address)
        @user.addresses << @secondary_address
        @user.save
      end
      
      it "should let a user create yet another address" do
        s = @user.sales.first
        s.mock_completed_payment
        post '/purchases', @purchase_params.merge("address" => @secondary_address_params)
        response.status.should be(302)
        
        u = @user
        u.sales.count.should eq 2
        u.sales.last.address_id.should eq u.addresses.last.id  # this latest sale should have the same address_id as the latest address
      end
      
      it "should let the user delete their unpaid purchases" do
        @user.sales.count.should eq 1
        delete '/sales/' + @sale.id.to_s
        @user.sales.count.should eq 0
      end
      
      it "should prevent the user from deleting their paid sales" do
        @sale.receipt_confirmed = Time.now
        @sale.save
        @user.sales.count.should eq 1
        delete '/sales/' + @sale.id.to_s
        @user.sales.count.should eq 1
      end
      
      it "should prevent the user from marking their sale as paid" do
        lambda {
          put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({receipt_confirmed: Time.now})
        }.should raise_error
      end
      
      it "should let the user change their address before it's DLed" do
        @user.sales.first.address_id.should_not eq @secondary_address.id
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge("address_id" => @secondary_address.id, line_item: @line_item_params)
        @user.sales.first.address_id.should eq @secondary_address.id
      end
      
      it "should prevent the user from changing the address of order marked as downloaded" do
        sale = @user.sales.first
        sale.prepped = true
        sale.save
        
        @user.sales.first.address_id.should_not eq @secondary_address.id
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge(address_id: @secondary_address.id, line_item: @line_item_params)
        @user.sales.first.address_id.should_not eq @secondary_address.id
      end
      
      it "should let the user update their qty" do
        li_id = @sale.line_items.first.id  # this is inprecise and works based on luck
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({line_item: {id: li_id, qty: "4"} })
        sale = Sale.find(@sale.id)
        sale.line_items.first.qty.should eq 4
        
        sale.total_amount.should eq 10370000
      end
      
      it "prevents the user from changing the qty if the value of their partial payments would exceed their cart cost" do
        # make partial payment
        @sale.bitcoin_payments.create(value: @sale.checkout_wallet.value_needed - 1)
        li_id = @sale.line_items.first.id
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({line_item: {id: li_id, qty: "4"} })
        @sale.reload
        @sale.line_items.first.qty.should eq 4
        # above is just for setting up a sale with 4 books in it, lol
        
        # make payments
        @sale.bitcoin_payments.create(:value => @sale.checkout_wallet.value_needed - 1)
        
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({line_item: {id: li_id, qty: "1"} })
        Sale.find(@sale.id).line_items.first.qty.should eq 4
        
      end
      
      it "Should allow the user to change their qty as long as this doesn't reduce the price of their order to below what they've paid" do
        beginning_qty = @sale.line_items.first.qty
        
        # make partial payment
        @sale.bitcoin_payments.create(value: @sale.checkout_wallet.value_needed - 1)
        li_id = @sale.line_items.first.id
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({line_item: {id: li_id, qty: "4"} })
        Sale.find(@sale.id).line_items.first.qty.should eq 4
      end
      
      it "should honor the quoted price if they update their order" do
        # set the line_items price to something that the system would not set it to according to
        # current btc exchange rate
        li = @sale.line_items.first
        original_line_item_price = li.price - 100000 # careful with this, if test fails, sanity check this number and that it's less that the discounts per item!
        li.price = original_line_item_price
        li.save
        li.calculate_fields!
        
        original_total_amount = @sale.total_amount
        
        # make partial payment
        @sale.bitcoin_payments.create(value: @sale.checkout_wallet.value_needed - 1)
        li_id = @sale.line_items.first.id
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({line_item: {id: li_id, qty: "4"} })
        
        # make sure the total_amount changes though...
        updated_sale = Sale.find(@sale.id)
        
        updated_sale.line_items.first.price.should eq original_line_item_price
        
        display_these = { "updated_sale.total_amount" => updated_sale.total_amount.to_s, "original_total_amount" => original_total_amount.to_s}
        (updated_sale.total_amount > (original_total_amount * 2)).should be true  # roughly figure that the sale is priced sanely, these values can break if shipping cost goes way up
        (updated_sale.total_amount < (original_total_amount * 4)).should be true  # this could break if shipping cost policies change to scale upwards
      end
      
      it "should not lose it's address after an update" do
        li_id = @sale.line_items.first.id
        put '/sales/' + @sale.id.to_s, sale: @sale_params.merge({line_item: {id: li_id, qty: "4"} })
        
        Sale.find(@sale.id).address.should_not be_nil
      end
      
    end
    
  end
  
end







