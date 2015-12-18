require "spec_helper"

describe EncryptionPairsController do
  describe "routing" do

    it "routes to #index" do
      get("/encryption_pairs").should route_to("encryption_pairs#index")
    end

    it "routes to #new" do
      get("/encryption_pairs/new").should route_to("encryption_pairs#new")
    end

    it "routes to #show" do
      get("/encryption_pairs/1").should route_to("encryption_pairs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/encryption_pairs/1/edit").should route_to("encryption_pairs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/encryption_pairs").should route_to("encryption_pairs#create")
    end

    it "routes to #update" do
      put("/encryption_pairs/1").should route_to("encryption_pairs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/encryption_pairs/1").should route_to("encryption_pairs#destroy", :id => "1")
    end

  end
end
