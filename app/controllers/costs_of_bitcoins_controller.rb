class CostsOfBitcoinsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /costs_of_bitcoins
  # GET /costs_of_bitcoins.json
  def index
    @costs_of_bitcoins = CostsOfBitcoin.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @costs_of_bitcoins }
    end
  end

  # GET /costs_of_bitcoins/1
  # GET /costs_of_bitcoins/1.json
  def show
    @costs_of_bitcoin = CostsOfBitcoin.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @costs_of_bitcoin }
    end
  end

  # GET /costs_of_bitcoins/new
  # GET /costs_of_bitcoins/new.json
  def new
    @costs_of_bitcoin = CostsOfBitcoin.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @costs_of_bitcoin }
    end
  end

  # GET /costs_of_bitcoins/1/edit
  def edit
    @costs_of_bitcoin = CostsOfBitcoin.find(params[:id])
  end

  # POST /costs_of_bitcoins
  # POST /costs_of_bitcoins.json
  def create
    @costs_of_bitcoin = CostsOfBitcoin.new(params[:costs_of_bitcoin])

    respond_to do |format|
      if @costs_of_bitcoin.save
        format.html { redirect_to @costs_of_bitcoin, notice: 'Costs of bitcoin was successfully created.' }
        format.json { render json: @costs_of_bitcoin, status: :created, location: @costs_of_bitcoin }
      else
        format.html { render action: "new" }
        format.json { render json: @costs_of_bitcoin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /costs_of_bitcoins/1
  # PUT /costs_of_bitcoins/1.json
  def update
    @costs_of_bitcoin = CostsOfBitcoin.find(params[:id])

    respond_to do |format|
      if @costs_of_bitcoin.update_attributes(params[:costs_of_bitcoin])
        format.html { redirect_to @costs_of_bitcoin, notice: 'Costs of bitcoin was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @costs_of_bitcoin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /costs_of_bitcoins/1
  # DELETE /costs_of_bitcoins/1.json
  def destroy
    @costs_of_bitcoin = CostsOfBitcoin.find(params[:id])
    @costs_of_bitcoin.destroy

    respond_to do |format|
      format.html { redirect_to costs_of_bitcoins_url }
      format.json { head :no_content }
    end
  end
end
