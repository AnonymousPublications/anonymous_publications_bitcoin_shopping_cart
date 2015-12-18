class PricingRule < ActiveRecord::Base
  attr_accessible :case_value, :condition, :discount_id, :discount_percent, :shipping_modifier, :shipping_plan_id
  
  belongs_to :shipping_plan
  belongs_to :discount
end
