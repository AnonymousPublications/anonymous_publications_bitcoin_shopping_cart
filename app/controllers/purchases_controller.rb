class PurchasesController < ApplicationController
  #GET /purchases/new
  def new
    @user = current_user
    # If the user already has a purchase open with us, redirect them to it
    if !@user.nil? and @user.has_purchases_lacking_all_payment_evidence?
      redirect_to sale_url_without_ajax_query(@user.sales.first_unpaid_lacking_all_evidence), notice: Msgs.has_unpaid_purchases
    end
    
    setup_cost_calculation_variables
  end
  
  # TODO:  Only allow 30 account creations/email creations per IP Address to prevent spaming...
  # but what about Tor users?  If it's an exit node, then we should do a captcha and a proof of work
  # trigger
  def create
    over_account_creation_limit_per_ip = check_if_over_account_creation_limit_per_ip?
    
    @product = Product.find_by_sku(params[:line_items]["0"][:product_sku])

    @cost_per_book = @product.get_item_cost_btc
    @shipping_cost_per_book = @product.get_shipping_cost
    
    @payment_to_tender = @product.get_item_cost_btc + @shipping_cost_per_book
    
    if current_user.nil?
      @user = User.create_instant_user(params[:user])
      @user.errors[:email][0] += ".  If you have an account, try logging in first." if !@user.errors.nil? and !@user.errors[:email].empty? # this is hackish, override teh User's error plz
      
      setup_cost_calculation_variables
      render 'new' and return if !@user.errors.empty?
      #redirect_to '/purchases/new' and return if !@user.errors.empty?
    else
      @user = current_user
    end
    
    # error if user has unpaid purchases
    redirect_to sale_url_without_ajax_query(@user.sales.first_unpaid_lacking_all_evidence), notice: Msgs.has_unpaid_purchases and return if (!@user.id.nil? and @user.has_purchases_lacking_all_payment_evidence?)
    
    
    # CREATE ADDRESS
    @address = Address.create_or_find_address(@user, params)
    render 'new' and return if !@address.errors.empty?
    
    render 'new' and return if line_item_invalid?(params[:line_item])
    
    # CREATE SALE AND LineItem
    @sale = Sale.create_instant_sale(@user, params[:line_item], @product, @address.id)
    
    session['pass'] = @user.password
    
    respond_to do |format|
      if @user.save and @address.save and @sale.save
        sign_in @user
        format.html { redirect_to sale_url_without_ajax_query(@sale), notice: 'Payment Still Required' }
        format.json { render json: @sale, status: :created, location: @sale }
      else
        format.html { render action: "new" }
        format.json { render json: @checkout_wallet.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def check_if_over_account_creation_limit_per_ip?()
    # 
    
  end
  
  def line_item_invalid?(line_item)
    line_item_qty = line_item["qty"].to_i
    
    if line_item_qty <= 0
      @line_item = LineItem.new
      @line_item.errors.add(:qty, "You need at least 1 thing or shipment will be impossible")
      flash = @line_item.errors
      return true
    end
    return false
  end
  
  def sale_url_without_ajax_query(sale)
    sale_url(sale) + "?new_payments_found=true"
  end
  
  def setup_cost_calculation_variables
    require 'cgi'
    
    @product = Product.find_by_sku("0001")
    
    # check if we need to do a query for exchange rate
    # and see if it can successfully perform the query
    
    flash.now[:notice] = "Using fallback BTC value (you're probably getting a discount!)" if !CostsOfBitcoin.performing_exchange_rate_queries_successfully?
    @cost_per_book = WorkHard.display_satoshi_as_btc(@product.get_item_cost_btc)
    @shipping_cost_per_book = WorkHard.display_satoshi_as_btc(@product.get_shipping_cost)
    li = LineItem.new(currency_used: "BTC", qty: 1)
    discount = Discount.find_by_name("Bitcoin Discount")
    @btc_discount = WorkHard.display_satoshi_as_btc(discount.determine_discount(li))
  end
  
end