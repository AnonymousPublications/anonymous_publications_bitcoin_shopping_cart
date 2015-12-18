class AddressesController < ApplicationController
  
  def index
    @address = Address.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @address }
    end
  end
  
  # GET /addresses/new
  # GET /addresses/new.json
  def new
    @address = Address.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @address }
    end
  end
  
  # POST /addresses
  # POST /addresses.json
  def create
    @user = current_user
    @address = @user.addresses.new(params[:address])
    @address.set_encryption_pair  # TODu:  before save would be nice... then clean factory out too

    respond_to do |format|
      if @address.save
        format.html { redirect_to @address, notice: 'Address was successfully created.' }
        format.json { render json: @address, status: :created, location: @address }
      else
        format.html { render action: "new" }
        format.json { render json: @address.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def show
    @user = current_user
    if current_user.nil?
      authorize! :show, current_user, :message => 'Not authorized as an administrator.'
    elsif current_user.has_role? :admin
      @address = Address.find(params[:id])
    else
      @address = @user.addresses.find(params[:id])
    end
    
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @address }
    end
  end
  
  # DELETE /addresses/1
  # DELETE /addresses/1.json
  def destroy
    if current_user.nil?
      authorize! :destroy, current_user, :message => 'Not authorized as an administrator.'
    elsif current_user.has_role? :admin
      @address = Address.find(params[:id])
    else
      @address = current_user.addresses.find(params[:id]) 
      # block if address is in use under the current_user's sales
      begin
        authorize! :destroy, current_user, :message => Msgs.address_in_use if current_user.sales.where( :address_id => @address.id).count > 0
      rescue Exception => exception
        redirect_to current_user, :alert => exception.message
        return
      end
    end
    
    @address.destroy

    respond_to do |format|
      format.html { redirect_to current_user }
      format.json { head :no_content }
    end
  end
end
