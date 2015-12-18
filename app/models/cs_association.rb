class CsAssociation < ActiveRecord::Base
  belongs_to :coupon
  belongs_to :sale
end
