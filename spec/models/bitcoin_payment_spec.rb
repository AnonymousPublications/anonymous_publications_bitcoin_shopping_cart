require 'spec_helper'

describe BitcoinPayment do
  before(:each) do
    @attr = {
      value: 20,
      input_address: "1lkj32l5kh123lkj",
      confirmations: "6",
      sale_id: "2",
      transaction_hash: "lkajsd",
      input_transaction_hash: "dsjakl",
      destination_address: "1lkjdsi1ji"
    }
    @attr_test = @attr.merge({ :test => "true" })
  end

  it "should create a new instance given a valid attribute" do
    BitcoinPayment.create!(@attr)
  end
  
end
