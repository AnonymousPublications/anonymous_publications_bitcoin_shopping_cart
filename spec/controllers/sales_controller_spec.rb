require 'spec_helper'

describe SalesController do
  before :each do
    login_user
    create_products
  end
  
  # This should return the minimal set of attributes required to create a valid
  # Sale. As you add validations to Sale, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { 
      "user_id" => @user.id,
      "address_id" => @user.addresses.first.id
    } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SalesController. Be sure to keep this updated too.
  let(:valid_session) { 
  }
  
  let(:pwtd_sku) {
    "0001"
  }
  
  describe "GET index" do
    it "assigns all sales as @sales" do
      sale = make_a_sale(valid_attributes)
      
      get :index, {}
      assigns(:sales).should eq([sale])
    end
  end

  describe "GET show" do
    it "assigns the requested sale as @sale" do
      sale = make_a_sale(valid_attributes)
      get :show, {:id => sale.to_param}
      assigns(:sale).should eq(sale)
    end
  end

  describe "GET new" do
    it "assigns a new sale as @sale" do
      get :new, {}
      assigns(:sale).should be_a_new(Sale)
    end
  end

  describe "GET edit" do
    it "assigns the requested sale as @sale" do
      sale = make_a_sale(valid_attributes)
      get :edit, {:id => sale.to_param}, valid_session
      assigns(:sale).should eq(sale)
    end
  end

  describe "PUT update" do
    it "should allow changing the address on undownloaded orders" do
      sale = make_a_sale(valid_attributes)
      
      put :update, {:id => sale.to_param,  :sale => { :address_id => @address_alt.id,
        :line_item => { :id => sale.line_items.first.id, :product_sku => pwtd_sku, :qty => "50" } } }
      
      Sale.find(sale.id).address_id.should be @address_alt.id
    end
    
    it "should prohibit the changing of addresses on downloaded orders"
    
    it "should allow changing the qty on unpaid orders" do
      sale = make_a_sale(valid_attributes)

      put :update, {:id => sale.to_param, :sale => { 
        :line_item => { :id => sale.line_items.first.to_param, :product_sku => pwtd_sku, :qty => "50" } } }
      
      Sale.find(sale.to_param).line_items.first.qty.should eq 50
    end
    
    it "should prevent changing the qty on paid orders" do
      sale = make_a_sale(valid_attributes)
      sale.receipt_confirmed = Time.now
      sale.save

      put :update, {:id => sale.to_param, :sale => { 
        :line_item => { :id => sale.line_items.first.id, :product_sku => pwtd_sku, :qty => "50" } } }
      
      Sale.find(sale.to_param).line_items.first.qty.should_not be 50
    end
  end

  describe "DELETE destroy" do
    
    it "won't destory the request if they've paid it" do
      sale = make_a_sale(valid_attributes)
      sale.receipt_confirmed = Time.now
      sale.save
      expect {
        delete :destroy, {:id => sale.to_param}, valid_session
      }.to change(Sale, :count).by(0)
    end
    
    it "destroys the requested sale if they're logged in and they own it" do
      sale = make_a_sale(valid_attributes)
      expect {
        delete :destroy, {:id => sale.to_param}, valid_session
      }.to change(Sale, :count).by(-1)
    end
    
    it "won't destroy the requested sale if they aren't logged in" do
      sign_out :user
      sale = make_a_sale(valid_attributes)
      expect {
        delete :destroy, {:id => sale.to_param}, valid_session
      }.to change(Sale, :count).by(0)
    end

    it "redirects to the current user" do
      sale = make_a_sale(valid_attributes)
      delete :destroy, {:id => sale.to_param}, valid_session
      response.should redirect_to(@user)  # sales_url
    end
  end
  
end


