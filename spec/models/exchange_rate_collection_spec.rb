require 'spec_helper'

describe ExchangeRateCollection do
  
  before :each do
    @a = create_valid_exchange_rate_collection
  end
  
  it "avg_30_days_values should be an array of Floats" do
    @a.avg_30_days_values.count.should eq 2
    @a.avg_30_days_values.first.class.should eq Float
  end
  
  it "avg_30_days_aggregate should be a Float" do
    @a.avg_30_days_aggregate.class.should eq Float
    @a.avg_30_days_aggregate.should eq 495.0
  end
  
  it "avg_7_days_aggregate should be a Float" do
    @a.avg_7_days_aggregate.class.should eq Float
    @a.avg_7_days_aggregate.should eq 625.0
  end
  
  it "avg_24_hours_aggregate should be a Float" do
    @a.avg_24_hours_aggregate.class.should eq Float
    @a.avg_24_hours_aggregate.should eq 605.0
  end
  
  it "should raise an exception if an attempt to run choose_suitable_exchange_rate occurs when there are no valid figures" do
    a = ExchangeRateCollection.new
    
    expect {
      a.choose_suitable_exchange_rate
    }.to raise_exception ExchangeRateCollection::InsufficientFactorsToCompleteCalculation
  end
  
  it "should work with incomplete entries" do
    @a << { :avg_24_hours=>590.0 }
    @a.avg_24_hours_aggregate.should eq 600.0
  end
  
  
  def create_valid_exchange_rate_collection
    a = ExchangeRateCollection.new
    
    # put in a single, valid exchange_rate_data hash
    # a << CostsOfBitcoin.map_data_to_uniform_hash($ExchangeRateResources.first, JSON.parse($ExchangeData))
    a << {:avg_30_days=>490.0, :avg_7_days=>620.0, :avg_24_hours=>600.0}
    a << {:avg_30_days=>500.0, :avg_7_days=>630.0, :avg_24_hours=>610.0}
    a
  end
end
