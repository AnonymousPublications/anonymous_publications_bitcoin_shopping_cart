require "spec_helper"

describe CheckoutWalletsController do
  describe "routing" do

    it "routes to #index" do
      get("/checkout_wallets").should route_to("checkout_wallets#index")
    end

    it "routes to #new" do
      get("/checkout_wallets/new").should route_to("checkout_wallets#new")
    end

    it "routes to #show" do
      get("/checkout_wallets/1").should route_to("checkout_wallets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/checkout_wallets/1/edit").should route_to("checkout_wallets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/checkout_wallets").should route_to("checkout_wallets#create")
    end

    it "routes to #update" do
      put("/checkout_wallets/1").should route_to("checkout_wallets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/checkout_wallets/1").should route_to("checkout_wallets#destroy", :id => "1")
    end

  end
end
