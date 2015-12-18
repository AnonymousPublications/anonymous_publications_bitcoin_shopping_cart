require 'spec_helper'
require 'support/controller_macros'

describe AdminPagesController do
  before :each do
    login_admin
    create_products
  end
  
  
  let(:valid_attributes) { { 
    "user_id" => @user.id,
    "address_id" => @user.addresses.first.id
  } }
  
  
  
  describe "GET index" do
    it "assigns proper stuff on index as production machine" do
      get :shipping_control, {}
      assigns(:qtys_rdy_for_shipping).should be_empty
    end
    
    it "assigns proper stuff on index as shipping machine" do
      get :shipping_control, {}
    end

  end
  
  describe "GET downloader_controls" do
    it "assigns the proper stuff and doesn't crash" do
      FactoryGirl.create(:user_with_1_book)

      get :downloader_controls
      # assigns(:qtys_rdy_for_shipping).should
      
    end
  end
  
  
end





