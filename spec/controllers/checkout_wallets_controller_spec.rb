require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.
=begin

describe CheckoutWalletsController do

  # This should return the minimal set of attributes required to create a valid
  # CheckoutWallet. As you add validations to CheckoutWallet, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "value_needed" => "1" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # CheckoutWalletsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all checkout_wallets as @checkout_wallets" do
      checkout_wallet = CheckoutWallet.create! valid_attributes
      get :index, {}, valid_session
      assigns(:checkout_wallets).should eq([checkout_wallet])
    end
  end

  describe "GET show" do
    it "assigns the requested checkout_wallet as @checkout_wallet" do
      checkout_wallet = CheckoutWallet.create! valid_attributes
      get :show, {:id => checkout_wallet.to_param}, valid_session
      assigns(:checkout_wallet).should eq(checkout_wallet)
    end
  end

  describe "GET new" do
    it "assigns a new checkout_wallet as @checkout_wallet" do
      get :new, {}, valid_session
      assigns(:checkout_wallet).should be_a_new(CheckoutWallet)
    end
  end

  describe "GET edit" do
    it "assigns the requested checkout_wallet as @checkout_wallet" do
      checkout_wallet = CheckoutWallet.create! valid_attributes
      get :edit, {:id => checkout_wallet.to_param}, valid_session
      assigns(:checkout_wallet).should eq(checkout_wallet)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new CheckoutWallet" do
        expect {
          post :create, {:checkout_wallet => valid_attributes}, valid_session
        }.to change(CheckoutWallet, :count).by(1)
      end

      it "assigns a newly created checkout_wallet as @checkout_wallet" do
        post :create, {:checkout_wallet => valid_attributes}, valid_session
        assigns(:checkout_wallet).should be_a(CheckoutWallet)
        assigns(:checkout_wallet).should be_persisted
      end

      it "redirects to the created checkout_wallet" do
        post :create, {:checkout_wallet => valid_attributes}, valid_session
        response.should redirect_to(CheckoutWallet.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved checkout_wallet as @checkout_wallet" do
        # Trigger the behavior that occurs when invalid params are submitted
        CheckoutWallet.any_instance.stub(:save).and_return(false)
        post :create, {:checkout_wallet => { "value_needed" => "invalid value" }}, valid_session
        assigns(:checkout_wallet).should be_a_new(CheckoutWallet)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        CheckoutWallet.any_instance.stub(:save).and_return(false)
        post :create, {:checkout_wallet => { "value_needed" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested checkout_wallet" do
        checkout_wallet = CheckoutWallet.create! valid_attributes
        # Assuming there are no other checkout_wallets in the database, this
        # specifies that the CheckoutWallet created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        CheckoutWallet.any_instance.should_receive(:update_attributes).with({ "value_needed" => "1" })
        put :update, {:id => checkout_wallet.to_param, :checkout_wallet => { "value_needed" => "1" }}, valid_session
      end

      it "assigns the requested checkout_wallet as @checkout_wallet" do
        checkout_wallet = CheckoutWallet.create! valid_attributes
        put :update, {:id => checkout_wallet.to_param, :checkout_wallet => valid_attributes}, valid_session
        assigns(:checkout_wallet).should eq(checkout_wallet)
      end

      it "redirects to the checkout_wallet" do
        checkout_wallet = CheckoutWallet.create! valid_attributes
        put :update, {:id => checkout_wallet.to_param, :checkout_wallet => valid_attributes}, valid_session
        response.should redirect_to(checkout_wallet)
      end
    end

    describe "with invalid params" do
      it "assigns the checkout_wallet as @checkout_wallet" do
        checkout_wallet = CheckoutWallet.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        CheckoutWallet.any_instance.stub(:save).and_return(false)
        put :update, {:id => checkout_wallet.to_param, :checkout_wallet => { "value_needed" => "invalid value" }}, valid_session
        assigns(:checkout_wallet).should eq(checkout_wallet)
      end

      it "re-renders the 'edit' template" do
        checkout_wallet = CheckoutWallet.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        CheckoutWallet.any_instance.stub(:save).and_return(false)
        put :update, {:id => checkout_wallet.to_param, :checkout_wallet => { "value_needed" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested checkout_wallet" do
      checkout_wallet = CheckoutWallet.create! valid_attributes
      expect {
        delete :destroy, {:id => checkout_wallet.to_param}, valid_session
      }.to change(CheckoutWallet, :count).by(-1)
    end

    it "redirects to the checkout_wallets list" do
      checkout_wallet = CheckoutWallet.create! valid_attributes
      delete :destroy, {:id => checkout_wallet.to_param}, valid_session
      response.should redirect_to(checkout_wallets_url)
    end
  end

end


=end