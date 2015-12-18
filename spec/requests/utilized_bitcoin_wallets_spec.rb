require 'spec_helper'

describe "UtilizedBitcoinWallets" do
  describe "GET /utilized_bitcoin_wallets" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get utilized_bitcoin_wallets_path
      response.status.should be(302)
    end
  end
end
