require "spec_helper"

describe CostsOfBitcoinsController do
  describe "routing" do

    it "routes to #index" do
      get("/costs_of_bitcoins").should route_to("costs_of_bitcoins#index")
    end

    it "routes to #new" do
      get("/costs_of_bitcoins/new").should route_to("costs_of_bitcoins#new")
    end

    it "routes to #show" do
      get("/costs_of_bitcoins/1").should route_to("costs_of_bitcoins#show", :id => "1")
    end

    it "routes to #edit" do
      get("/costs_of_bitcoins/1/edit").should route_to("costs_of_bitcoins#edit", :id => "1")
    end

    it "routes to #create" do
      post("/costs_of_bitcoins").should route_to("costs_of_bitcoins#create")
    end

    it "routes to #update" do
      put("/costs_of_bitcoins/1").should route_to("costs_of_bitcoins#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/costs_of_bitcoins/1").should route_to("costs_of_bitcoins#destroy", :id => "1")
    end

  end
end
