require "spec_helper"

describe ShippingPlansController do
  describe "routing" do

    it "routes to #index" do
      get("/shipping_plans").should route_to("shipping_plans#index")
    end

    it "routes to #new" do
      get("/shipping_plans/new").should route_to("shipping_plans#new")
    end

    it "routes to #show" do
      get("/shipping_plans/1").should route_to("shipping_plans#show", :id => "1")
    end

    it "routes to #edit" do
      get("/shipping_plans/1/edit").should route_to("shipping_plans#edit", :id => "1")
    end

    it "routes to #create" do
      post("/shipping_plans").should route_to("shipping_plans#create")
    end

    it "routes to #update" do
      put("/shipping_plans/1").should route_to("shipping_plans#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/shipping_plans/1").should route_to("shipping_plans#destroy", :id => "1")
    end

  end
end
