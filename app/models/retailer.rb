class Retailer < ActiveRecord::Base
  attr_accessible :address_id, :name, :email, :phone, :fax, :map_link, :notes
  belongs_to :address
  
  def method_missing(method, *args)
    attr = method.to_sym
    return address.send(attr) if address.respond_to? attr
  end
end
