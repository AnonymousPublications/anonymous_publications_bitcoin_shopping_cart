require 'spec_helper'

describe "Users" do
  include RequestHelpers
  let(:authed_user) { create_logged_in_user }

  describe "GET /users as guest" do
    it "request login" do
      get users_path
      response.status.should be(302)
    end
  end
  
  describe "GET /users as normal user" do
    it "request admin login" do
      get users_path
      response.status.should be(302)
    end
  end
  
  describe "GET /users as admin" do
    it "it works when signed on" do
      get users_path(authed_user)
      response.status.should be(200)
    end
  end
  
end
