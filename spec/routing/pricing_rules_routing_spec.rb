require "spec_helper"

describe PricingRulesController do
  describe "routing" do

    it "routes to #index" do
      get("/pricing_rules").should route_to("pricing_rules#index")
    end

    it "routes to #new" do
      get("/pricing_rules/new").should route_to("pricing_rules#new")
    end

    it "routes to #show" do
      get("/pricing_rules/1").should route_to("pricing_rules#show", :id => "1")
    end

    it "routes to #edit" do
      get("/pricing_rules/1/edit").should route_to("pricing_rules#edit", :id => "1")
    end

    it "routes to #create" do
      post("/pricing_rules").should route_to("pricing_rules#create")
    end

    it "routes to #update" do
      put("/pricing_rules/1").should route_to("pricing_rules#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/pricing_rules/1").should route_to("pricing_rules#destroy", :id => "1")
    end

  end
end
