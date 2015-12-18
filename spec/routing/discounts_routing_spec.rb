require "spec_helper"

describe DiscountsController do
  describe "routing" do

    it "routes to #index" do
      get("/discounts").should route_to("discounts#index")
    end

    it "routes to #new" do
      get("/discounts/new").should route_to("discounts#new")
    end

    it "routes to #show" do
      get("/discounts/1").should route_to("discounts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/discounts/1/edit").should route_to("discounts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/discounts").should route_to("discounts#create")
    end

    it "routes to #update" do
      put("/discounts/1").should route_to("discounts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/discounts/1").should route_to("discounts#destroy", :id => "1")
    end

  end
end
