require "spec_helper"

describe BitcoinPaymentsController do
  describe "routing" do

    it "routes to #index" do
      get("/bitcoin_payments").should route_to("bitcoin_payments#index")
    end

    it "routes to #new" do
      get("/bitcoin_payments/new").should route_to("bitcoin_payments#new")
    end

    it "routes to #show" do
      get("/bitcoin_payments/1").should route_to("bitcoin_payments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/bitcoin_payments/1/edit").should route_to("bitcoin_payments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/bitcoin_payments").should route_to("bitcoin_payments#create")
    end

    it "routes to #update" do
      put("/bitcoin_payments/1").should route_to("bitcoin_payments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/bitcoin_payments/1").should route_to("bitcoin_payments#destroy", :id => "1")
    end

  end
end
