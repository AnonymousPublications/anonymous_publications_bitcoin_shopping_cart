require 'spec_helper'

describe "EncryptionPairs" do
  describe "GET /encryption_pairs" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get encryption_pairs_path
      response.status.should be(302)
    end
  end
end
