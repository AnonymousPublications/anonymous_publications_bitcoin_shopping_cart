class EncryptionPairsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_user!
  
  # GET /encryption_pairs
  # GET /encryption_pairs.json
  def index
    @encryption_pairs = EncryptionPair.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @encryption_pairs }
    end
  end

  # GET /encryption_pairs/1
  # GET /encryption_pairs/1.json
  def show
    @encryption_pair = EncryptionPair.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @encryption_pair }
    end
  end

  # GET /encryption_pairs/new
  # GET /encryption_pairs/new.json
  def new
    @encryption_pair = EncryptionPair.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @encryption_pair }
    end
  end

  # GET /encryption_pairs/1/edit
  def edit
    @encryption_pair = EncryptionPair.find(params[:id])
  end

  # POST /encryption_pairs
  # POST /encryption_pairs.json
  def create
    @encryption_pair = EncryptionPair.new(params[:encryption_pair])

    respond_to do |format|
      if @encryption_pair.save
        format.html { redirect_to @encryption_pair, notice: 'Encryption pair was successfully created.' }
        format.json { render json: @encryption_pair, status: :created, location: @encryption_pair }
      else
        format.html { render action: "new" }
        format.json { render json: @encryption_pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /encryption_pairs/1
  # PUT /encryption_pairs/1.json
  def update
    @encryption_pair = EncryptionPair.find(params[:id])

    respond_to do |format|
      if @encryption_pair.update_attributes(params[:encryption_pair])
        format.html { redirect_to @encryption_pair, notice: 'Encryption pair was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @encryption_pair.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /encryption_pairs/1
  # DELETE /encryption_pairs/1.json
  def destroy
    @encryption_pair = EncryptionPair.find(params[:id])
    @encryption_pair.destroy

    respond_to do |format|
      format.html { redirect_to encryption_pairs_url }
      format.json { head :no_content }
    end
  end
end
