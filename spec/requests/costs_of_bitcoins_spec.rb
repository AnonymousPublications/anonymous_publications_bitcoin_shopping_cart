require 'spec_helper'

describe "CostsOfBitcoins" do
  describe "GET /costs_of_bitcoins" do
    it "prompts login! (now write some real specs)" do
      get costs_of_bitcoins_path
      response.status.should be(302)
    end
  end
end
