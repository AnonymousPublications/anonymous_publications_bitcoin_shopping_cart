require "spec_helper"

describe UtilizedBitcoinWalletsController do
  describe "routing" do

    it "routes to #index" do
      get("/utilized_bitcoin_wallets").should route_to("utilized_bitcoin_wallets#index")
    end

    it "routes to #new" do
      get("/utilized_bitcoin_wallets/new").should route_to("utilized_bitcoin_wallets#new")
    end

    it "routes to #show" do
      get("/utilized_bitcoin_wallets/1").should route_to("utilized_bitcoin_wallets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/utilized_bitcoin_wallets/1/edit").should route_to("utilized_bitcoin_wallets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/utilized_bitcoin_wallets").should route_to("utilized_bitcoin_wallets#create")
    end

    it "routes to #update" do
      put("/utilized_bitcoin_wallets/1").should route_to("utilized_bitcoin_wallets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/utilized_bitcoin_wallets/1").should route_to("utilized_bitcoin_wallets#destroy", :id => "1")
    end

  end
end
