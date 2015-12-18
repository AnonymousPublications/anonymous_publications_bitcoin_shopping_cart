class UtilizedBitcoinWalletsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /utilized_bitcoin_wallets
  # GET /utilized_bitcoin_wallets.json
  def index
    @utilized_bitcoin_wallets = UtilizedBitcoinWallet.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @utilized_bitcoin_wallets }
    end
  end

  # GET /utilized_bitcoin_wallets/1
  # GET /utilized_bitcoin_wallets/1.json
  def show
    @utilized_bitcoin_wallet = UtilizedBitcoinWallet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @utilized_bitcoin_wallet }
    end
  end

  # GET /utilized_bitcoin_wallets/new
  # GET /utilized_bitcoin_wallets/new.json
  def new
    @utilized_bitcoin_wallet = UtilizedBitcoinWallet.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @utilized_bitcoin_wallet }
    end
  end

  # GET /utilized_bitcoin_wallets/1/edit
  def edit
    @utilized_bitcoin_wallet = UtilizedBitcoinWallet.find(params[:id])
  end

  # POST /utilized_bitcoin_wallets
  # POST /utilized_bitcoin_wallets.json
  def create
    @utilized_bitcoin_wallet = UtilizedBitcoinWallet.new(params[:utilized_bitcoin_wallet])

    respond_to do |format|
      if @utilized_bitcoin_wallet.save
        format.html { redirect_to @utilized_bitcoin_wallet, notice: 'Utilized bitcoin wallet was successfully created.' }
        format.json { render json: @utilized_bitcoin_wallet, status: :created, location: @utilized_bitcoin_wallet }
      else
        format.html { render action: "new" }
        format.json { render json: @utilized_bitcoin_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /utilized_bitcoin_wallets/1
  # PUT /utilized_bitcoin_wallets/1.json
  def update
    @utilized_bitcoin_wallet = UtilizedBitcoinWallet.find(params[:id])

    respond_to do |format|
      if @utilized_bitcoin_wallet.update_attributes(params[:utilized_bitcoin_wallet])
        format.html { redirect_to @utilized_bitcoin_wallet, notice: 'Utilized bitcoin wallet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @utilized_bitcoin_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /utilized_bitcoin_wallets/1
  # DELETE /utilized_bitcoin_wallets/1.json
  def destroy
    @utilized_bitcoin_wallet = UtilizedBitcoinWallet.find(params[:id])
    @utilized_bitcoin_wallet.destroy

    respond_to do |format|
      format.html { redirect_to utilized_bitcoin_wallets_url }
      format.json { head :no_content }
    end
  end
end
