class ReadyForShipmentBatchesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /ready_for_shipment_batches
  # GET /ready_for_shipment_batches.json
  def index
    @ready_for_shipment_batches = ReadyForShipmentBatch.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ready_for_shipment_batches }
    end
  end

  # GET /ready_for_shipment_batches/1
  # GET /ready_for_shipment_batches/1.json
  def show
    @ready_for_shipment_batch = ReadyForShipmentBatch.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ready_for_shipment_batch }
    end
  end

  # GET /ready_for_shipment_batches/new
  # GET /ready_for_shipment_batches/new.json
  def new
    @ready_for_shipment_batch = ReadyForShipmentBatch.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ready_for_shipment_batch }
    end
  end

  # GET /ready_for_shipment_batches/1/edit
  def edit
    @ready_for_shipment_batch = ReadyForShipmentBatch.find(params[:id])
  end

  # POST /ready_for_shipment_batches
  # POST /ready_for_shipment_batches.json
  def create
    @ready_for_shipment_batch = ReadyForShipmentBatch.new(params[:ready_for_shipment_batch])

    respond_to do |format|
      if @ready_for_shipment_batch.save
        format.html { redirect_to @ready_for_shipment_batch, notice: 'Ready for shipment batch was successfully created.' }
        format.json { render json: @ready_for_shipment_batch, status: :created, location: @ready_for_shipment_batch }
      else
        format.html { render action: "new" }
        format.json { render json: @ready_for_shipment_batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ready_for_shipment_batches/1
  # PUT /ready_for_shipment_batches/1.json
  def update
    @ready_for_shipment_batch = ReadyForShipmentBatch.find(params[:id])

    respond_to do |format|
      if @ready_for_shipment_batch.update_attributes(params[:ready_for_shipment_batch])
        format.html { redirect_to @ready_for_shipment_batch, notice: 'Ready for shipment batch was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ready_for_shipment_batch.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ready_for_shipment_batches/1
  # DELETE /ready_for_shipment_batches/1.json
  def destroy
    @ready_for_shipment_batch = ReadyForShipmentBatch.find(params[:id])
    @ready_for_shipment_batch.destroy

    respond_to do |format|
      format.html { redirect_to ready_for_shipment_batches_url }
      format.json { head :no_content }
    end
  end
end
