require 'spec_helper'

describe BitcoinPaymentsController do
  before :each do
    login_admin
    create_products
  end

  # This should return the minimal set of attributes required to create a valid
  # BitcoinPayment. As you add validations to BitcoinPayment, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {
      value: 4500000,
      input_address: "1lkj32l5kh123lkj",
      confirmations: "6",
      sale_id: "2",
      transaction_hash: "lkajsd",
      input_transaction_hash: "dsjakl",
      destination_address: ENV["SHOPPING_CART_WALLET"]
    } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # BitcoinPaymentsController. Be sure to keep this updated too.
  let(:valid_session) { {} }
  
  before :each do
    # I have to create a sale first with a secret authorization token
    # so just use a factory...
    @user = FactoryGirl.create(:user_with_1_book_unpaid)
    @sale = @user.sales.first
    @cw = @sale.checkout_wallet
    
    @attr = {
      value: WorkHard.convert_back_to_satoshi(@sale.total_amount),
      input_address: @cw.input_address,
      confirmations: "6",
      sale_id: @sale.id.to_s,
      transaction_hash: @cw.transaction_hash,
      input_transaction_hash: @cw.input_transaction_hash,
      destination_address: ENV["SHOPPING_CART_WALLET"],
      secret_authorization_token: @cw.secret_authorization_token
    }
  end

  describe "GET index" do
    it "assigns all bitcoin_payments as @bitcoin_payments" do
      bitcoin_payment = BitcoinPayment.create! valid_attributes
      get :index_bitcoins
      assigns(:bitcoin_payments).should eq([bitcoin_payment])
    end
  end


  describe "POST create" do
    describe "with valid params" do
      it "creates a new BitcoinPayment" do
        expect {
          post :create, {:bitcoin_payment => valid_attributes}
        }.to change(BitcoinPayment, :count).by(1)
      end

      it "assigns a newly created bitcoin_payment as @bitcoin_payment" do
        post :create, {:bitcoin_payment => valid_attributes}
        assigns(:bitcoin_payment).should be_a(BitcoinPayment)
        assigns(:bitcoin_payment).should be_persisted
      end

      it "redirects to the created bitcoin_payment" do
        post :create, {:bitcoin_payment => valid_attributes}
        response.should redirect_to(BitcoinPayment.last)
      end
      
      it "should create a new BitcoinPayment record and mark it fully paid and all that shit when things go right" do
        post :trigger_confirmation, @attr
        
        BitcoinPayment.count.should eq 1
        CheckoutWallet.find(@cw.id).fully_paid?.should be true
      end
      
      it "should be able to update an existing record and increment the confirmations as appropriate" do
        post :trigger_confirmation, @attr.merge(confirmations: 3)
        
        BitcoinPayment.count.should eq 1
        bp = BitcoinPayment.first
        bp.confirmations.should eq 3
        bp.sale.checkout_wallet.technically_paid?.should be true
        bp.sale.checkout_wallet.fully_paid?.should be false
        
        post :trigger_confirmation, @attr
        BitcoinPayment.first.confirmations.should eq 6
        BitcoinPayment.count.should eq 1
      end
      
    end

    describe "with invalid params" do
      
      it "shouldn't accept invalid dest_addresses" do
        post :trigger_confirmation, @attr.merge({destination_address: "3"})
        
        BitcoinPayment.count.should eq 0
      end
      
      it "shouldn't accept invalid secret_auth_tokens" do
        post :trigger_confirmation, @attr.merge({secret_authorization_token: "3"})
        
        BitcoinPayment.count.should eq 0
      end
      
      it "shouldn't accept fewer than 6 confirmations" do
        post :trigger_confirmation, @attr.merge({confirmations: "3"})
        
        BitcoinPayment.where('confirmations < 6').count.should eq 1
      end
      
    end
    
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested bitcoin_payment" do
        bitcoin_payment = BitcoinPayment.create! valid_attributes
        # Assuming there are no other bitcoin_payments in the database, this
        # specifies that the BitcoinPayment created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(BitcoinPayment).to receive(:update_attributes).with({ "value" => "" })
        #BitcoinPayment.any_instance.should_receive(:update_attributes).with({ "value" => "" })
        put :update, {:id => bitcoin_payment.to_param, :bitcoin_payment => { "value" => "" }}
      end

      it "assigns the requested bitcoin_payment as @bitcoin_payment" do
        bitcoin_payment = BitcoinPayment.create! valid_attributes
        put :update, {:id => bitcoin_payment.to_param, :bitcoin_payment => valid_attributes}
        assigns(:bitcoin_payment).should eq(bitcoin_payment)
      end

      it "redirects to the bitcoin_payment" do
        bitcoin_payment = BitcoinPayment.create! valid_attributes
        put :update, {:id => bitcoin_payment.to_param, :bitcoin_payment => valid_attributes}
        response.should redirect_to(bitcoin_payment)
      end
    end

    describe "with invalid params" do
      it "assigns the bitcoin_payment as @bitcoin_payment" do
        bitcoin_payment = BitcoinPayment.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        BitcoinPayment.any_instance.stub(:save).and_return(false)
        put :update, {:id => bitcoin_payment.to_param, :bitcoin_payment => { "value" => "invalid value" }}
        assigns(:bitcoin_payment).should eq(bitcoin_payment)
      end

      it "re-renders the 'edit' template" do
        bitcoin_payment = BitcoinPayment.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        BitcoinPayment.any_instance.stub(:save).and_return(false)
        put :update, {:id => bitcoin_payment.to_param, :bitcoin_payment => { "value" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested bitcoin_payment" do
      bitcoin_payment = BitcoinPayment.create! valid_attributes
      expect {
        delete :destroy, {:id => bitcoin_payment.to_param}
      }.to change(BitcoinPayment, :count).by(-1)
    end

    it "redirects to the bitcoin_payments list" do
      bitcoin_payment = BitcoinPayment.create! valid_attributes
      delete :destroy, {:id => bitcoin_payment.to_param}
      response.should redirect_to(bitcoin_payments_url)
    end
  end

end

