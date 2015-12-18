class ShippingPlan < ActiveRecord::Base
  attr_accessible :name, :shipping_base_amount, :product_id
  
  has_many :pricing_rules
  belongs_to :product
end
