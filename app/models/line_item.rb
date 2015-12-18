class LineItem < ActiveRecord::Base
  attr_accessible :description, :currency_used, :discount, :price, :shipping_cost_usd, :shipping_cost_btc, :price_extend, :qty, :product_sku, :original_id
  attr_accessor :discount_fixed_amount_value, :price_after_fixed_discounts, :price_after_all_discounts
  belongs_to :sale
  belongs_to :product, :foreign_key => :product_sku
  
  has_many :discounts, :class_name => "LineItem",
    :foreign_key => "discounted_item_id"
  
  belongs_to :line_item, :class_name => "LineItem", :foreign_key => "discounted_item_id"
  
  has_many :cl_associations
  has_many :coupons, through: :cl_associations, uniq: true
  
  
  extend Importable
  
  # TODO:  remove this code, and replace that ins sales_controller#update
  # with the propper one... where everything, including discounts are recalculated
  # LineItem#get_calculated_attribute_hash(attr)
  def calculate_fields!
    m_price_extend = qty * price
    attributes = { :price_extend => m_price_extend }
    self.update_attributes(attributes)
  end
  
  def self.get_calculated_attribute_hash(attributes)
    qty = attributes[:qty]
    m_price_extend = qty * attributes[:price]
    price_extend_hash = { :price_extend => m_price_extend }
    
    product = Product.find_by_sku(attributes[:product_sku])
    product_shipping_cost_usd = product.shipping_cost_usd
    shipping_hash = { :shipping_cost_usd => find_shipping_based_on_qty(product_shipping_cost_usd, qty),
        :shipping_cost_btc => find_shipping_based_on_qty(CostsOfBitcoin.usd_to_satoshi(product_shipping_cost_usd), qty)
    }
    
    calculated_fields_hash = shipping_hash.merge(price_extend_hash)
    
    attributes.merge(calculated_fields_hash)
  end
  
  # for creating new line_items, calculated fields are calculated here
  def self.pew(attributes)
    attributes = get_calculated_attribute_hash(attributes)
    
    li = self.new(attributes)
  end
  
  def find_shipping_based_on_qty(shipping_cost_usd, qty)
    shipping_cost_usd * 1 #qty.to_f
  end
  
  # TODu:  re-write this to use the shipping_plans table
  def self.find_shipping_based_on_qty(shipping_cost_usd, qty)
    shipping_cost_usd * 1 #qty.to_f
  end
  
  def calculate_and_attach_discount_items
    self.discounts.delete_all
    
    discount_line_items = predict_price_after_discounts!.last
    discount_line_items.each {|d| self.discounts << d}
    
    self
  end
  
  
  # returns 
  #   price_after_all_discounts: a decimal indicating how much the line item's price will be after the discounts are applied
  #   discounts:  An array of discount line items that the line_item should have
  #   line_item#price_after_fixed_discounts is set
  #   line_item#price_after_all_discounts is set
  #
  def predict_price_after_discounts!
    m_discounts = []
    f = build_discount_items :fixed_amount
    m_discounts += f
    
    self.price_after_fixed_discounts = (self.price * self.qty).to_i + m_discounts.each {|discount| discount.price_extend }.sum(&:price_extend).to_i

    p = build_discount_items :percentage
    m_discounts += p
    
    self.price_after_all_discounts = (self.price * self.qty).to_i + m_discounts.each {|discount| discount.price_extend }.sum(&:price_extend).to_i
    
    if self.price_after_all_discounts < 0
      discount_amount = self.price_after_all_discounts * -1
      discount_sku = Product.find_by_name("Discount").sku
      discount_attributes = {:product_sku => discount_sku, :qty => 1, 
                      :currency_used => "BTC", 
                      :price => discount_amount, :price_extend => discount_amount,
                      :description => "Discount to prevent line_item from less than zero condition" }
                      
      self.discounts.create(discount_attributes)
    end
    
    [self.price_after_all_discounts, m_discounts]
  end
  
  
  def build_discount_items(m_type)
    m_discounts = self.product.discounts.where(discount_type: m_type.to_s)
    # get all coupons.each { |c| c.discount }
    coupon_discounts = coupons.collect {|c| c.discount}.select {|d|d.discount_type == m_type.to_s}
    m_discounts += coupon_discounts
    
    m_discount_items = []
    m_discounts.each do |discount|
      d = make_discount_line_item(discount)
      m_discount_items << d unless d.nil?
    end
    m_discount_items
  end
  
  
  def make_discount_line_item(discount)
    discount_sku = Product.find_by_name("Discount").sku
    discount_amount = discount.determine_discount(self)
    d_qty = discount.discount_type == "fixed_amount" ? self.qty : 1
    
    if !discount_amount.nil? and discount_amount < 0.0
      discount_attributes = {:product_sku => discount_sku, :qty => d_qty, 
                      :currency_used => "BTC", 
                      :price => discount_amount, :price_extend => (discount_amount * d_qty),
                      :description => discount.name }
      
      LineItem.new(discount_attributes)
    end
  end
  
  
  def predict_price_of_n(n)
    old_qty = self.qty
    self.qty = n
    
    self.price_after_all_discounts = predict_price_after_discounts!.first
    
    m_price_after_shipping = self.price_after_all_discounts + shipping_cost_btc
    
    (m_price_after_shipping).round(-4)
  end
  
  
  def display_price_extend
    WorkHard.display_satoshi_as_btc(price_extend).to_s
  end
  
end
