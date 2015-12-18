class Discount < ActiveRecord::Base
  attr_accessible :discount_type, :name, :active
  
  has_many :pricing_rules
  has_many :coupons
  
  has_many :pd_associations
  has_many :products, through: :pd_associations, uniq: true
  
  
  # This function checks the sale/line item to see if the discount in question applies to the sale, and if so
  # what amount of discount should be yielded
  def determine_discount(line_item)
    # line_item = self
    discount = self
    # line_item.price_after_fixed_discounts = line_item.price_extend if line_item.price_after_fixed_discounts.nil?
    style = discount[:discount_type].to_sym
    
    if style == :percentage  # only does discount by qty right now...
      discount_percent = search_rules_for_applicable_discount(discount.pricing_rules, line_item)
      discount_amount = ( discount_percent * -1.0 * line_item.price_after_fixed_discounts ).round(-4)
    elsif style == :fixed_amount
      discount_amount = (search_rules_for_applicable_discount(discount.pricing_rules, line_item) * -1.0).round(-4)
    elsif style == :modify_shipping
      line_item.shipping_cost_usd = line_item.shipping_cost_usd * discount.pricing_rules.first.discount_percent.to_f
      line_item.shipping_cost_btc = line_item.shipping_cost_btc * discount.pricing_rules.first.discount_percent.to_f
    end
    
    return discount_amount
  end
  
  # Given a set of rules, and a line_item, determines what amount of discount should be yielded to the customer's sale
  def search_rules_for_applicable_discount(rules, line_item)
    # what line of code tell discount.active?
    rules.each do |rule|
      if rule[:condition].nil?
        condition = true
        case_value = true
        discount_percent = eval rule[:discount_percent]
      else
        condition = eval rule[:condition]
        discount_percent = eval rule[:discount_percent]
        case_value = eval rule[:case_value]
      end
      
      if condition.class == Range
        condition.each do |i|
          return discount_percent if i == case_value
        end
      elsif condition.class == Fixnum or (condition.class == TrueClass or condition.class == FalseClass) or (condition.class == String and !condition.empty?)
        return discount_percent if condition == case_value
      else # this is for empty conditions which symbolize the default, last resort condition
        default_discount = discount_percent
      end
    end
    
    return default_discount
  end
  
  # Generates a new coupon for the discount record in question
  # expects a discount, and then a hash of params for Coupon to be built with like :usage_limit, disabled_message, etc...
  def generate_coupon(coupon_options = {})
    discount = self
    params = coupon_options
    usage_limit = params[:usage_limit]
    disabled_message = params[:disabled_message]
    disabled_message = "This coupon has been disabled for a reason which forgot to be specified." if disabled_message.nil?
    token = params[:token]
    token = Coupon.gen_token if token.nil?
    
    coupon_params = { :usage_limit => usage_limit, :disabled_message => disabled_message,
                      :token => token, :product_id => params[:product_id] }
    
    discount.coupons.create(coupon_params)
  end
  
end
