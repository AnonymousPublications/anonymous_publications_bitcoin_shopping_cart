class Msgs
  def self.has_unpaid_purchases
    "You already have this purchase started.  To initiate book shipment, please pay the associated bitcoin address listed below."
  end
  
  def self.address_in_use
    "That address is in use for one of your sales.  Update the purchase order or just leave it be.  If you're worried about security, don't worry, it's encrypted in such a manor that only the shipping crew can decrypt it and the U.S. Government doesn't know who's in the shipping crew or where the secured/offline label printing machine is located."
  end
  
  def self.sale_not_found
    "Sale not found."
  end
end