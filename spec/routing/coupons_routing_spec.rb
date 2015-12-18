require "spec_helper"

describe CouponsController do
  describe "routing" do

    it "routes to #index" do
      get("/coupons").should route_to("coupons#index")
    end

    it "routes to #new" do
      get("/coupons/new").should route_to("coupons#new")
    end

    it "routes to #show" do
      get("/coupons/1").should route_to("coupons#show", :id => "1")
    end

    it "routes to #edit" do
      get("/coupons/1/edit").should route_to("coupons#edit", :id => "1")
    end

    it "routes to #create" do
      post("/coupons").should route_to("coupons#create")
    end

    it "routes to #update" do
      put("/coupons/1").should route_to("coupons#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/coupons/1").should route_to("coupons#destroy", :id => "1")
    end

  end
end
