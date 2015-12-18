class CostsOfBitcoin < ActiveRecord::Base
  attr_accessible :cost_in_usd, :qty_of_satoshi
  attr_accessor :emergency
  
  @@last_exchange_rate_query = nil
  
  def self.last_exchange_rate_query
    @@last_exchange_rate_query
  end
  
  def self.reset_temp_data
    @@last_exchange_rate_query = nil
  end
  
  # rounds to .0000 percision
  def self.usd_to_satoshi(price_usd)
    bitcoin_cost = CostsOfBitcoin.current_exchange_rate
    satoshi_cost = bitcoin_cost/100000000.0
    # TODO:  need to round to nearest whole integer...
    (price_usd / satoshi_cost).round(-4)
  end

  # TODO:  Fixing that it rounds harshly!!!!
  def self.btc_to_usd(price_btc)
    bitcoin_cost = CostsOfBitcoin.current_exchange_rate
    (price_btc * bitcoin_cost).round(2)
  end
  
  def self.satoshi_to_btc_decimal(price_satoshi)
    price_satoshi/100000000.0
  end
  
  # This function returns the cost in USD to buy a BTC worth of Satoshi...
  def self.current_exchange_rate
    # Look at the latest exchange rate... and see if it's older than 1 day
    last_record = self.last
    
    if last_record.nil? or last_record.exchange_rate_is_stale?
      
      if last_record.nil? and we_havent_querried_recently?
        new_exchange_rate = self.get_new_exchange_rate
      else
        new_exchange_rate = CostsOfBitcoin.emergency_discount
      end
      
      return new_exchange_rate.cost_in_usd
    end
    
    return last_record.cost_in_usd
  end
  
  # TODu:
  # this should be refactored so the we_haven't_querried_recently? check is inside the get_new_exchange_rate method
  def self.performing_exchange_rate_queries_successfully?
    if exchange_rate_is_stale?
      if we_havent_querried_recently?
        # perform a query
        cob = get_new_exchange_rate
        if cob.emergency
          return false
        else
          return true
        end
      else
        # if our exchange rate is stale and we have queried recently, then something is wrong
        return false
      end
    else
      return true
    end
  end
  
  def self.we_havent_querried_recently?
    return true if @@last_exchange_rate_query.nil? or (Time.zone.now - @@last_exchange_rate_query)/60 >= 15
    return false
  end
  
  def self.exchange_rate_is_stale?
    last_rate = self.last
    return true if last_rate.nil?
    last_rate.exchange_rate_is_stale?
  end
  
  def exchange_rate_is_stale?
    (Time.zone.now - self.created_at)/60/60/24 >= 1
  end
  
  # This is a bit confusing, but if we have no way of figuring out what the exchange rate if for USD/BTC, we 
  # fallback to this value as an emergency amounts
  def self.emergency_discount
    cob = CostsOfBitcoin.new({:qty_of_satoshi => 100000000, :cost_in_usd => $EmergencyBtcCost})
    cob.emergency = true
    cob
  end
  
  # once daily, it pulls down the 30d, 7d, and 24h averages of BTC and takes the lowest value 
  def self.get_new_exchange_rate
    @@last_exchange_rate_query = Time.zone.now
    
    exchange_rate_collection = collect_data_needed_for_exchange_rate_calculation
    
    calculate_exchange_rate(exchange_rate_collection) # oddly returns a CostsOfBitcoin object representing useful exchange rate
  end
  
  def self.collect_data_needed_for_exchange_rate_calculation
    exchange_rate_collection = ExchangeRateCollection.new
    $ExchangeRateResources.each do |resource|
      begin
        response_data = query_for_exchange_data(resource[:uri])
        exchange_rate_collection << map_data_to_uniform_hash(resource, response_data)
      rescue Exception => exception
        Message.emergency("Probably failed to query_for_exchange_data from #{resource[:uri]}", "#{__FILE__}:#{__LINE__}\n" + exception.message)
        exchange_rate_collection << "query fail"
      end
    end
    exchange_rate_collection
  end
  
  def self.calculate_exchange_rate(exchange_rate_collection)
    begin
      average_to_use = exchange_rate_collection.choose_suitable_exchange_rate
    rescue  Exception => exception
      cob = CostsOfBitcoin.last
    
      if cob.nil?
        # Send an admin alert message that we had trouble looking up an average today
        Message.emergency("Failed to query_for_exchange_data and there's no CostsOfBitcoin in database!", "#{__FILE__}:#{__LINE__}\n" + exception.message)
        # return 'something' that can be used as an average just so the app can continue for an unwitting customer
        return CostsOfBitcoin.emergency_discount
      else
        Message.emergency("Failed to query_for_exchange_data, but have a fallback", "#{__FILE__}:#{__LINE__}\n" + exception.message)
        return cob # return the last value in the database
      end
      
    end
    
    return CostsOfBitcoin.create!({:qty_of_satoshi => 100000000, :cost_in_usd => average_to_use})
  end
  
  # source: "http://example.com/api"
  # avg_30_days
  # avg_7_days
  # avg_24_hours
  # TODu:  Need a new table, exchange_datas source:string avg_30_days
  def self.query_for_exchange_data(uri)
    # HTTP query a reputable website to get the exchange rate value or average really...
    exchange_uri = uri # "https://api.bitcoincharts.com/v1/weighted_prices.json"  # that https might not work!

    if $IsDebuggingResponses # ENV["RAILS_ENV"] == "test" or ENV["RAILS_ENV"] == "development"  # TODu: check that this will work when mocking responses is false for tests
      exchange_data = $ExchangeData
    else
      exchange_data = HTTParty.get(exchange_uri).body
    end
    
    exchange_data = JSON.parse(exchange_data)
    exchange_data
  end
  
  def self.map_data_to_uniform_hash(exchange_rate_resource, response_data)
    # uniform_hash = { avg_30_days: 0, avg_7_days: 0, avg_24_hours: 0 }
    uniform_hash = {}
    
    response_data = response_data.dup
    template = exchange_rate_resource.dup.select { |k, v| k == :avg_30_days or k == :avg_7_days or k == :avg_24_hours }
    
    template.each do |k, v|
      next if v == ""
      uniform_hash[k] = eval("response_data#{v}").to_f    # LOL, this is so silly!  Refactor some day, Nokogiri will fix this
    end
    
    uniform_hash
  end
  
  def to_s
    "qty_of_satoshi: #{self[:qty_of_satoshi]};    cost_in_usd: #{self[:cost_in_usd]}"
  end
  
end
