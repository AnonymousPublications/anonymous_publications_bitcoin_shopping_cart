require "spec_helper"

describe RetailersController do
  describe "routing" do

    it "routes to #index" do
      get("/retailers").should route_to("retailers#index")
    end

    it "routes to #new" do
      get("/retailers/new").should route_to("retailers#new")
    end

    it "routes to #show" do
      get("/retailers/1").should route_to("retailers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/retailers/1/edit").should route_to("retailers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/retailers").should route_to("retailers#create")
    end

    it "routes to #update" do
      put("/retailers/1").should route_to("retailers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/retailers/1").should route_to("retailers#destroy", :id => "1")
    end

  end
end
