class PricingRulesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /pricing_rules
  # GET /pricing_rules.json
  def index
    @pricing_rules = PricingRule.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @pricing_rules }
    end
  end

  # GET /pricing_rules/1
  # GET /pricing_rules/1.json
  def show
    @pricing_rule = PricingRule.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @pricing_rule }
    end
  end

  # GET /pricing_rules/new
  # GET /pricing_rules/new.json
  def new
    @pricing_rule = PricingRule.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @pricing_rule }
    end
  end

  # GET /pricing_rules/1/edit
  def edit
    @pricing_rule = PricingRule.find(params[:id])
  end

  # POST /pricing_rules
  # POST /pricing_rules.json
  def create
    @pricing_rule = PricingRule.new(params[:pricing_rule])

    respond_to do |format|
      if @pricing_rule.save
        format.html { redirect_to @pricing_rule, notice: 'Pricing rule was successfully created.' }
        format.json { render json: @pricing_rule, status: :created, location: @pricing_rule }
      else
        format.html { render action: "new" }
        format.json { render json: @pricing_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /pricing_rules/1
  # PUT /pricing_rules/1.json
  def update
    @pricing_rule = PricingRule.find(params[:id])

    respond_to do |format|
      if @pricing_rule.update_attributes(params[:pricing_rule])
        format.html { redirect_to @pricing_rule, notice: 'Pricing rule was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @pricing_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pricing_rules/1
  # DELETE /pricing_rules/1.json
  def destroy
    @pricing_rule = PricingRule.find(params[:id])
    @pricing_rule.destroy

    respond_to do |format|
      format.html { redirect_to pricing_rules_url }
      format.json { head :no_content }
    end
  end
end
