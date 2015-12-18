class Coupon < ActiveRecord::Base
  attr_accessible :discount_id, :product_id, :applies_to, :disabled_message, :enabled, :token, :usage_limit
  
  validates_presence_of :discount_id
  
  belongs_to :discount
  belongs_to :product
  
  has_many :cs_associations
  has_many :sales, through: :cs_associations, uniq: true
  
  has_many :cl_associations
  has_many :line_items, through: :cl_associations, uniq: true
  
  def self.gen_token
    (User.random_string(8) + "disc").split("").shuffle.join
  end
  
  def used_up?
    return false if usage_limit.nil? or usage_limit == 0
    
    if applies_to? :product
      line_items.count >= usage_limit
    elsif applies_to? :sale
      sales.count >= usage_limit
    end
  end
  
  def applies_to
    if product_id.nil?
      :sale
    else
      :product
    end
  end
  
  def applies_to?(sym)
    applies_to == sym
  end
  
  # This function attempts to apply a coupon to a sale or line_item of a sale
  # Returns "true" if all went well
  # else returns a string describing why things didn't go well
  def apply_to!(sale, line_item = nil)
    coupon = self
    
    return "coupon_usage_limit_exceeded" if coupon.used_up?
    return "no_sale_found_for_user" if sale.nil?
    
    if coupon.applies_to?(:sale)
      sale.coupons << coupon
    elsif coupon.applies_to?(:product)
      li = sale.line_items.find_by_product_sku(coupon.product.sku)
      return "no_eligible_line_items" if li.nil?
      li.coupons << coupon
      
      li.calculate_and_attach_discount_items
    end
    
    "true"
  end
  
  
  def self.contains_wave_shipping_coupon?
    discount = Discount.find_by_name("Wave Shipping Discount")
    return false if discount.nil?
    
    c = self.find_by_discount_id(discount.id)
    
    !c.nil?
  end
  
end
