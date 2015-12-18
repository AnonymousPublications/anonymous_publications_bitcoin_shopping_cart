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
describe PricingRulesController do

  # This should return the minimal set of attributes required to create a valid
  # PricingRule. As you add validations to PricingRule, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { { "case_value" => "MyString" } }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # PricingRulesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all pricing_rules as @pricing_rules" do
      pricing_rule = PricingRule.create! valid_attributes
      get :index, {}, valid_session
      assigns(:pricing_rules).should eq([pricing_rule])
    end
  end

  describe "GET show" do
    it "assigns the requested pricing_rule as @pricing_rule" do
      pricing_rule = PricingRule.create! valid_attributes
      get :show, {:id => pricing_rule.to_param}, valid_session
      assigns(:pricing_rule).should eq(pricing_rule)
    end
  end

  describe "GET new" do
    it "assigns a new pricing_rule as @pricing_rule" do
      get :new, {}, valid_session
      assigns(:pricing_rule).should be_a_new(PricingRule)
    end
  end

  describe "GET edit" do
    it "assigns the requested pricing_rule as @pricing_rule" do
      pricing_rule = PricingRule.create! valid_attributes
      get :edit, {:id => pricing_rule.to_param}, valid_session
      assigns(:pricing_rule).should eq(pricing_rule)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PricingRule" do
        expect {
          post :create, {:pricing_rule => valid_attributes}, valid_session
        }.to change(PricingRule, :count).by(1)
      end

      it "assigns a newly created pricing_rule as @pricing_rule" do
        post :create, {:pricing_rule => valid_attributes}, valid_session
        assigns(:pricing_rule).should be_a(PricingRule)
        assigns(:pricing_rule).should be_persisted
      end

      it "redirects to the created pricing_rule" do
        post :create, {:pricing_rule => valid_attributes}, valid_session
        response.should redirect_to(PricingRule.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved pricing_rule as @pricing_rule" do
        # Trigger the behavior that occurs when invalid params are submitted
        PricingRule.any_instance.stub(:save).and_return(false)
        post :create, {:pricing_rule => { "case_value" => "invalid value" }}, valid_session
        assigns(:pricing_rule).should be_a_new(PricingRule)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        PricingRule.any_instance.stub(:save).and_return(false)
        post :create, {:pricing_rule => { "case_value" => "invalid value" }}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested pricing_rule" do
        pricing_rule = PricingRule.create! valid_attributes
        # Assuming there are no other pricing_rules in the database, this
        # specifies that the PricingRule created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        PricingRule.any_instance.should_receive(:update_attributes).with({ "case_value" => "MyString" })
        put :update, {:id => pricing_rule.to_param, :pricing_rule => { "case_value" => "MyString" }}, valid_session
      end

      it "assigns the requested pricing_rule as @pricing_rule" do
        pricing_rule = PricingRule.create! valid_attributes
        put :update, {:id => pricing_rule.to_param, :pricing_rule => valid_attributes}, valid_session
        assigns(:pricing_rule).should eq(pricing_rule)
      end

      it "redirects to the pricing_rule" do
        pricing_rule = PricingRule.create! valid_attributes
        put :update, {:id => pricing_rule.to_param, :pricing_rule => valid_attributes}, valid_session
        response.should redirect_to(pricing_rule)
      end
    end

    describe "with invalid params" do
      it "assigns the pricing_rule as @pricing_rule" do
        pricing_rule = PricingRule.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PricingRule.any_instance.stub(:save).and_return(false)
        put :update, {:id => pricing_rule.to_param, :pricing_rule => { "case_value" => "invalid value" }}, valid_session
        assigns(:pricing_rule).should eq(pricing_rule)
      end

      it "re-renders the 'edit' template" do
        pricing_rule = PricingRule.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        PricingRule.any_instance.stub(:save).and_return(false)
        put :update, {:id => pricing_rule.to_param, :pricing_rule => { "case_value" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested pricing_rule" do
      pricing_rule = PricingRule.create! valid_attributes
      expect {
        delete :destroy, {:id => pricing_rule.to_param}, valid_session
      }.to change(PricingRule, :count).by(-1)
    end

    it "redirects to the pricing_rules list" do
      pricing_rule = PricingRule.create! valid_attributes
      delete :destroy, {:id => pricing_rule.to_param}, valid_session
      response.should redirect_to(pricing_rules_url)
    end
  end

end

=end