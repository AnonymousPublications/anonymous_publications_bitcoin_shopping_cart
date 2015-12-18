class ExchangeRateCollection < Array
  # meta avg_30_days_values, avg_7_days_values, avg_24_hours_values, avg_30_days_aggregate
  
  # use the smallest of the two values so we don't get ripped off by wierd speculator caused issues (fucking douche nozzels!)
  # but maybe we should throw out the 30d value if it's different by more than 20% the difference of 7d -24h and the lowest...
  # economically, that's a really shitty habit actually... because every time there's a crash, there's a 7day lag for all retailers
  # 
  # ... If    7d - 24h = ++ then we have a decline in BTC value...
  #  ...    in that case we want to use the 7d valuation in the hopes that we can fix BTC's depreciating value
  # 
  # ... If    7d - 24h = -- then we are getting over a decline, and thus we should take the 24h value
  #
  # ... If    30d is greater than all, then we need to take it's value since we hit a crash that the market 
  #         is having trouble getting rid of???
  # 
  def choose_suitable_exchange_rate
    # relies on avg_24_hours, avg_7_days, avg_30_days
    relies_on :avg_24_hours, :avg_7_days, :avg_30_days
    
    avg_24_hours = choose_suitable_avg_24_hours
    avg_7_days = avg_7_days_aggregate
    avg_30_days = avg_30_days_aggregate
    
    if avg_24_hours < avg_7_days
      average_to_use = avg_7_days
    else
      average_to_use = avg_24_hours
    end
    average_to_use = avg_30_days if avg_30_days > average_to_use
    
    average_to_use
  end
  
  # use the highest value found in our cache of avg_24_hours
  def choose_suitable_avg_24_hours
    expose_selected_values(:avg_24_hours).max
  end
  
  def expose_selected_values(selector)
    values_to_return = []
    self.each do |exchange_rate|
      next if exchange_rate.nil? or exchange_rate[selector].nil?
      values_to_return << exchange_rate[selector]
    end
    return values_to_return.compact
  end
  
  def expose_aggregation(selector)
    vals = expose_selected_values(selector)
    vals.sum / vals.count
  end
  
  
  def method_missing(method, *args)
    if method.to_s =~ /_values$/
      attr = method.to_s.sub("_values","").to_sym
      method_to_invoke = :expose_selected_values
    elsif method.to_s =~ /_aggregate$/
      attr = method.to_s.sub("_aggregate","").to_sym
      method_to_invoke = :expose_aggregation
    end
    
    if child_has_key_for? attr
      return send method_to_invoke, attr
    end
    
  end
  
  def child_has_key_for?(key_name)
    each do |exchange_data|
      return true if exchange_data.include? key_name
    end
    return false
  end
  
  def relies_on(*args)
    args.each do |value|
      if !child_has_key_for?(value)
        raise InsufficientFactorsToCompleteCalculation, "Missing Factor:  #{value.to_s}\n" + 
          "Perhaps a web query failed and the ExchangeRateCollection object couldn't " +
          "get enough factors to operate normally."
      end
    end
  end
  
  # returns an array of all avg_30_days_values
  #def avg_30_days_values
  #  avg_30_days = []
  #  self.each do |exchange_rate|
  #    avg_30_days << exchange_rate[:avg_30_days]
  #  end
  #  avg_30_days.compact
  #end
  
  # returns sum of avg_30_days_values
  #def avg_30_days_aggregate
  #  avg_30_days_values.sum / avg_30_days_values.count
  #end
  
  class InsufficientFactorsToCompleteCalculation < Exception;end
  
end