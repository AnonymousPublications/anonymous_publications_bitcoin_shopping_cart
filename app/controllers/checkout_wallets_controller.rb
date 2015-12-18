class CheckoutWalletsController < ApplicationController
  # GET /checkout_wallets
  # GET /checkout_wallets.json
  def index
    authorize! :index, current_user, :message => 'Not authorized as an administrator.'
    @checkout_wallets = CheckoutWallet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @checkout_wallets }
    end
  end

  # GET /checkout_wallets/1
  # GET /checkout_wallets/1.json
  def show
    authorize! :show, current_user, :message => 'Not authorized as an administrator.'
    @checkout_wallet = CheckoutWallet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @checkout_wallet }
    end
  end

  # GET /checkout_wallets/new
  # GET /checkout_wallets/new.json
  def new
    @checkout_wallet = CheckoutWallet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @checkout_wallet }
    end
  end

  # GET /checkout_wallets/1/edit
  def edit
    authorize! :edit, current_user, :message => 'Not authorized as an administrator.'
    @checkout_wallet = CheckoutWallet.find(params[:id])
  end

  # POST /checkout_wallets
  # POST /checkout_wallets.json
  def create
    authorize! :create, current_user, :message => 'Not authorized as an administrator.'
    @checkout_wallet = CheckoutWallet.new(params[:checkout_wallet])

    respond_to do |format|
      if @checkout_wallet.save
        format.html { redirect_to @checkout_wallet, notice: 'Checkout wallet was successfully created.' }
        format.json { render json: @checkout_wallet, status: :created, location: @checkout_wallet }
      else
        format.html { render action: "new" }
        format.json { render json: @checkout_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /checkout_wallets/1
  # PUT /checkout_wallets/1.json
  def update
    authorize! :update, current_user, :message => 'Not authorized as an administrator.'
    @checkout_wallet = CheckoutWallet.find(params[:id])

    respond_to do |format|
      if @checkout_wallet.update_attributes(params[:checkout_wallet])
        format.html { redirect_to @checkout_wallet, notice: 'Checkout wallet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @checkout_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checkout_wallets/1
  # DELETE /checkout_wallets/1.json
  def destroy
    authorize! :destroy, current_user, :message => 'Not authorized as an administrator.'
    @checkout_wallet = CheckoutWallet.find(params[:id])
    @checkout_wallet.destroy

    respond_to do |format|
      format.html { redirect_to checkout_wallets_url }
      format.json { head :no_content }
    end
  end
end
