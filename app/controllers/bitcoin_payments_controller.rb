class BitcoinPaymentsController < ApplicationController
  # GET /bitcoin_payments
  # GET /bitcoin_payments.json
  def index_bitcoins  # index
    authorize! :index, current_user, :message => 'Not authorized as an administrator.'
    @bitcoin_payments = BitcoinPayment.all

    respond_to do |format|
      format.html { render 'index' } # index.html.erb
      format.json { render json: @bitcoin_payments }
    end
  end
  
  # GET /bitcoin_payments_callback
  def trigger_confirmation
    bitcoin_payment_params = params.dup
    render :text => "*ok*" and return if bitcoin_payment_params[:test] == "true"
    
    
    @related_sale = Sale.find(bitcoin_payment_params[:sale_id])
    
    # block_payments_with_erroneous_destination_address
    render :text => "*ok*" and return if bitcoin_payment_params[:destination_address] != @related_sale.checkout_wallet.destination_address
    
    render :text => "*ok*" and return if bitcoin_payment_params[:secret_authorization_token] != @related_sale.checkout_wallet.secret_authorization_token
    
    bitcoin_payment_params = filter_invalid_params(bitcoin_payment_params)
    @bitcoin_payment = create_or_update_bitcoin_payment(bitcoin_payment_params)
      
    if @bitcoin_payment.save
      if bitcoin_payment_params['confirmations'].to_i < 6
        render :text => "keep us updated"
      else
        render :text => "*ok*"
      end
      @related_sale.checkout_wallet.calculate_if_payment_complete
    end
  end
  
  # TODu move to model
  def create_or_update_bitcoin_payment(bitcoin_payment_params)
    
    @bitcoin_payment = BitcoinPayment.find_by_transaction_hash(bitcoin_payment_params['transaction_hash'])
    
    if @bitcoin_payment.nil?
      @bitcoin_payment = BitcoinPayment.new(bitcoin_payment_params) 
    else
      @bitcoin_payment.assign_attributes(bitcoin_payment_params)
    end
    
    @bitcoin_payment
  end
  
  # /new_payments_found
  def new_payments_found
    authenticate_user!
    
    render :text => user_has_new_payments_confirmed?(current_user)
  end
  
  def user_has_new_payments_confirmed?(user)
    total_differences = 0.0
    user.sales.each_unpaid do |sale|
      old_paid_amount = sale.get_previously_discovered_payment_value
      new_paid_amount = sale.get_confirmed_payments
      total_differences += new_paid_amount - old_paid_amount
    end
    return true if total_differences > 0
    false
  end
  
  # TODu: send to model
  def filter_invalid_params(bitcoin_payment_params)
    white_list = ["test", "value", "input_address", "confirmations", "sale_id", "transaction_hash", "input_transaction_hash", "destination_address"]
    
    filtered_params = bitcoin_payment_params.select { |k| WorkHard.within_list?(k, white_list) }
  end
  
  # GET /bitcoin_payments/1
  # GET /bitcoin_payments/1.json
  def show
    authorize! :show, current_user, :message => 'Not authorized as an administrator.'
    @bitcoin_payment = BitcoinPayment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @bitcoin_payment }
    end
  end

  # GET /bitcoin_payments/new
  # GET /bitcoin_payments/new.json
  def new
    @bitcoin_payment = BitcoinPayment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @bitcoin_payment }
    end
  end

  # GET /bitcoin_payments/1/edit
  def edit
    @bitcoin_payment = BitcoinPayment.find(params[:id])
  end


  # the only time this function would be hit would be when the admin is playing with stuff
  # POST /bitcoin_payments
  # POST /bitcoin_payments.json
  def create
    authorize! :create, current_user, :message => 'Not authorized as an administrator.'
    @bitcoin_payment = BitcoinPayment.new(params[:bitcoin_payment])

    respond_to do |format|
      if @bitcoin_payment.save
        format.html { redirect_to @bitcoin_payment, notice: 'Bitcoin payment was successfully created.' }
        format.json { render json: @bitcoin_payment, status: :created, location: @bitcoin_payment }
      else
        format.html { render action: "new" }
        format.json { render json: @bitcoin_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /bitcoin_payments/1
  # PUT /bitcoin_payments/1.json
  def update
    authorize! :update, current_user, :message => 'Not authorized as an administrator.'
    @bitcoin_payment = BitcoinPayment.find(params[:id])

    respond_to do |format|
      if @bitcoin_payment.update_attributes(params[:bitcoin_payment])
        format.html { redirect_to @bitcoin_payment, notice: 'Bitcoin payment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bitcoin_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bitcoin_payments/1
  # DELETE /bitcoin_payments/1.json
  def destroy
    authorize! :destroy, current_user, :message => 'Not authorized as an administrator.'
    @bitcoin_payment = BitcoinPayment.find(params[:id])
    @bitcoin_payment.destroy

    respond_to do |format|
      format.html { redirect_to bitcoin_payments_url }
      format.json { head :no_content }
    end
  end
end
