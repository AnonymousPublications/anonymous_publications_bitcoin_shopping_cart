class SalesController < ApplicationController
  before_filter :authenticate_user!
  # GET /sales
  # GET /sales.json
  def index
    if current_user.nil?
      authorize! :index, current_user, :message => 'Not authorized as an administrator.'
    elsif current_user.has_role? :admin
      @sales = Sale.all
    else
      @sales = current_user.sales
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @sales }
    end
  end

  # GET /sales/1
  # GET /sales/1.json
  def show
    if current_user.nil?
      authorize! :show, current_user, :message => 'Not authorized as an administrator or owner of record.'
    elsif current_user.has_role? :admin
      @sale = Sale.find(params[:id])
      @address = Address.find(@sale.address_id)
    else
      @sale = current_user.sales.find(params[:id])
      @address = current_user.addresses.find(@sale.address_id)
    end
    
    remainder_to_pay_btc = @sale.remainder_to_pay
    @remainder_to_pay = WorkHard.display_satoshi_as_btc(remainder_to_pay_btc)
    @is_partially_paid = (@sale.total_amount - @remainder_to_pay)
    
    @pass = session['pass']
    session['pass'] = nil
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @sale }
    end
  end

  # GET /sales/new
  # GET /sales/new.json
  def new
    @sale = Sale.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @sale }
    end
  end

  # GET /sales/1/edit
  def edit
    @user = current_user
    @sale = @user.sales.find(params[:id])
  end

respond_to do |wants|
  wants.html do
    
  end
  wants.js {  }
end  # PUT /sales/1
  # PUT /sales/1.json
  def update
    checkout_wallet_changed = false
    @user = current_user
    @sale = @user.sales.find(params[:id])
    @line_item = @sale.line_items.find(params[:sale][:line_item][:id]) if (!@sale.receipt_confirmed and !@sale.technically_paid?)
    parameters = params[:sale]
    
    if blocked_from_changing_sale?  # Do this a better way or clean it up into a controller method, does CANCAN do this?
      parameters = {}
    end
    
    # if line_item_qty changes, we need to perform this block
    if (!@sale.receipt_confirmed and !@sale.technically_paid?) and params[:sale][:line_item][:qty].to_i != @line_item.qty and valid_qty_changes?(parameters)
      @line_item.update_attributes(params[:sale][:line_item])
      @line_item.calculate_fields!
      @sale.calculate_discounts
    end
    
    sale_params = parameters.slice!("line_item")
    
    respond_to do |format|
      if @sale.update_attributes(sale_params)
        format.html { redirect_to @sale}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @sale.errors, status: :unprocessable_entity }
      end
    end
  end

  # TODu:  I wanna move this into model, but at the same time, look at all the attributes I'm setting... and misc logic...
  #   maybe this should be split up into multiple functions
  # qty can be changed if they increase the amount of books they're buying, or if they reduce the amount of books they're buying 
  # They should have account balances too???  Like they're overpayments can be stored as credits?  That would be so fun
  def valid_qty_changes?(parameters)
    @line_item = @sale.line_items.find(parameters[:line_item][:id].to_i)
    product = @line_item.product
    @new_qty = parameters[:line_item][:qty].to_i
    @old_qty = @line_item.qty

    @line_item.assign_attributes(qty: @new_qty)
    
    @new_price = @line_item.predict_price_of_n(@new_qty)
    @new_price = @new_price
    
    # return false if they're hackers changing a discount item
    # TODu: remove below line, can't happen now right?
    # flash[:error] = "You can't change a discount line_item" and return false if product.is_discount
    # return false if they're reducing a qty value to less than what they've paid in their checkout_wallet
    flash[:error] = "You can't reduce your sale's qty more than what you've already paid with bitcoins." and return false if trying_to_reduce_the_purchase_qty_to_less_than_whats_already_paid?
    
    return true
  end
  
  def trying_to_reduce_the_purchase_qty_to_less_than_whats_already_paid?
    (@sale.unconfirmed_value_paid > @new_price) and @new_qty < @old_qty
  end

  # DELETE /sales/1
  # DELETE /sales/1.json
  def destroy
    if current_user.nil?
      authorize! :destroy, current_user, :message => 'Not authorized as an administrator.'
    elsif current_user.has_role? :admin
      @sale = Sale.find(params[:id])
    else
      begin
        @sale = current_user.sales.find(params[:id])
      rescue
        authorize! :destroy, current_user, :message => Msgs.sale_not_found
      end
      
      begin
        authorize! :destroy, current_user, :message => "That sale has already been paid for, it can't be deleted." if (@sale.receipt_confirmed || @sale.technically_paid?)
      rescue Exception => exception
        redirect_to current_user, :alert => exception.message
        return
      end
    end

    @sale.destroy

    respond_to do |format|
      format.html { redirect_to current_user }
      format.json { head :no_content }
    end
  end
  
  def blocked_from_changing_sale?
    @sale.prepped
  end
  
  
  # GET /sales/apply_coupon_to_sale?token=occupy&sale_id=1
  # The customer uses this function to put a coupon on their sale over ajax
  # To apply a discount to a sale, create a coupon for that sale of the discount desired
  # ie sale.coupons.create(discount)
  def apply_coupon_to_sale
    token = params[:token]
    sale_id = params[:sale_id]
    
    coupon = Coupon.find_by_token(token)
    
    unless coupon.nil?
      sale = current_user.sales.find(sale_id)
      
      render :text => coupon.apply_to!(sale)
    else
      render :text => "invalid_coupon_token"
    end
  end
  
end
