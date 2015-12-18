# Coupon LineItem Association
class ClAssociation < ActiveRecord::Base
  belongs_to :coupon
  belongs_to :line_item
end
