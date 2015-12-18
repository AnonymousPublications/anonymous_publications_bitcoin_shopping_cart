class PdAssociation < ActiveRecord::Base
  belongs_to :product
  belongs_to :discount
end