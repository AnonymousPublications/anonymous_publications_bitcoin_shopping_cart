class ShippingPlansController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /shipping_plans
  # GET /shipping_plans.json
  def index
    @shipping_plans = ShippingPlan.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shipping_plans }
    end
  end

  # GET /shipping_plans/1
  # GET /shipping_plans/1.json
  def show
    @shipping_plan = ShippingPlan.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shipping_plan }
    end
  end

  # GET /shipping_plans/new
  # GET /shipping_plans/new.json
  def new
    @shipping_plan = ShippingPlan.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shipping_plan }
    end
  end

  # GET /shipping_plans/1/edit
  def edit
    @shipping_plan = ShippingPlan.find(params[:id])
  end

  # POST /shipping_plans
  # POST /shipping_plans.json
  def create
    @shipping_plan = ShippingPlan.new(params[:shipping_plan])

    respond_to do |format|
      if @shipping_plan.save
        format.html { redirect_to @shipping_plan, notice: 'Shipping plan was successfully created.' }
        format.json { render json: @shipping_plan, status: :created, location: @shipping_plan }
      else
        format.html { render action: "new" }
        format.json { render json: @shipping_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shipping_plans/1
  # PUT /shipping_plans/1.json
  def update
    @shipping_plan = ShippingPlan.find(params[:id])

    respond_to do |format|
      if @shipping_plan.update_attributes(params[:shipping_plan])
        format.html { redirect_to @shipping_plan, notice: 'Shipping plan was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @shipping_plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shipping_plans/1
  # DELETE /shipping_plans/1.json
  def destroy
    @shipping_plan = ShippingPlan.find(params[:id])
    @shipping_plan.destroy

    respond_to do |format|
      format.html { redirect_to shipping_plans_url }
      format.json { head :no_content }
    end
  end
end
