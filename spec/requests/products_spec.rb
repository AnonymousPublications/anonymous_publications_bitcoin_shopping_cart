require 'spec_helper'

describe "Products" do
  describe "GET /products" do
    it "works! (now write some real specs)" do
      get products_path
      response.status.should be(302)
    end

  end
end
