class AddressErrorsController < ApplicationController
  
  # POST manage_shipping_errors.... man this is getting messy fast...
  def index
    @address_error = AddressError.new
    # Need to fix bug where addresses with errors are included in @sales too...
    @sales = Sale.current_batch_that_was_shippable + Sale.unshippable
    @sales = @sales.map { |s| Sale.find s["id"] }
    
    @addresses = @sales.map {|s| s.address }
    
    @number_of_pages_to_show = ((@addresses.count/30)+1)
    @number_of_labels_per_page = 30
    
    render :layout => "address_labels"# false
  end
  
  def update
    @addresses = params[:address]
    
    unless @addresses.nil?
      @addresses.each do |id, address|
        a = Address.find id
        
        if address["erroneous"]
          a.update_attributes(erroneous: true)
          a.sale.update_attributes(:shipped => nil)
        else
          a.update_attributes(erroneous: false)
        end
      end
    end
    
    redirect_to "/address_errors", :notice => "Changes Saved."
  end
end