class RetailersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /retailers
  # GET /retailers.json
  def index
    @retailers = Retailer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @retailers }
    end
  end

  # GET /retailers/1
  # GET /retailers/1.json
  def show
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @retailer }
    end
  end

  # GET /retailers/new
  # GET /retailers/new.json
  def new
    @retailer = Retailer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @retailer }
    end
  end

  # GET /retailers/1/edit
  def edit
    @retailer = Retailer.find(params[:id])
  end

  # POST /retailers
  # POST /retailers.json
  def create
    @retailer = Retailer.new(params[:retailer])

    respond_to do |format|
      if @retailer.save
        format.html { redirect_to @retailer, notice: 'Retailer was successfully created.' }
        format.json { render json: @retailer, status: :created, location: @retailer }
      else
        format.html { render action: "new" }
        format.json { render json: @retailer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /retailers/1
  # PUT /retailers/1.json
  def update
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      if @retailer.update_attributes(params[:retailer])
        format.html { redirect_to @retailer, notice: 'Retailer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @retailer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /retailers/1
  # DELETE /retailers/1.json
  def destroy
    @retailer = Retailer.find(params[:id])
    @retailer.destroy

    respond_to do |format|
      format.html { redirect_to retailers_url }
      format.json { head :no_content }
    end
  end
end
