class Product < ActiveRecord::Base
  attr_accessible :name, :description, :material, :digital_copy, :thumbnail, :category, :is_discount, :price_usd, :qty_on_hand, :qty_ordered, :shipping_cost_usd, :sku, :taxable
  has_many :line_items
  has_many :coupons
  has_one :shipping_plan
  
  has_many :pd_associations
  has_many :discounts, through: :pd_associations, uniq: true
  
  # TODO: rename to _satoshi
  def get_item_cost_btc
    CostsOfBitcoin.usd_to_satoshi(price_usd)
  end
  
  def get_shipping_cost
    CostsOfBitcoin.usd_to_satoshi(shipping_cost_usd)
  end
  
end