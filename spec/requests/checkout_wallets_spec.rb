require 'spec_helper'

describe "CheckoutWallets" do
  describe "GET /checkout_wallets" do
    it "block users if not logged in" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get checkout_wallets_path
      response.status.should be(302)
    end
  end
end
