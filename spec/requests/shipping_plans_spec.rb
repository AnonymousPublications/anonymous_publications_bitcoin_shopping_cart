require 'spec_helper'

describe "ShippingPlans" do
  describe "GET /shipping_plans" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get shipping_plans_path
      response.status.should be(302)
    end
  end
end
