class DiscountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /discounts
  # GET /discounts.json
  def index
    @discounts = Discount.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @discounts }
    end
  end

  # GET /discounts/1
  # GET /discounts/1.json
  def show
    @discount = Discount.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @discount }
    end
  end

  # GET /discounts/new
  # GET /discounts/new.json
  def new
    @discount = Discount.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @discount }
    end
  end

  # GET /discounts/1/edit
  def edit
    @discount = Discount.find(params[:id])
  end

  # POST /discounts
  # POST /discounts.json
  def create
    @discount = Discount.new(params[:discount])

    respond_to do |format|
      if @discount.save
        format.html { redirect_to @discount, notice: 'Discount was successfully created.' }
        format.json { render json: @discount, status: :created, location: @discount }
      else
        format.html { render action: "new" }
        format.json { render json: @discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /discounts/1
  # PUT /discounts/1.json
  def update
    @discount = Discount.find(params[:id])

    respond_to do |format|
      if @discount.update_attributes(params[:discount])
        format.html { redirect_to @discount, notice: 'Discount was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @discount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /discounts/1
  # DELETE /discounts/1.json
  def destroy
    @discount = Discount.find(params[:id])
    @discount.destroy

    respond_to do |format|
      format.html { redirect_to discounts_url }
      format.json { head :no_content }
    end
  end
end
