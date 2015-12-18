class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
  end

  def show
    if current_user.nil?
      authorize! :show, current_user, :message => 'Not authorized as an administrator.'
    elsif current_user.has_role? :admin
      @user = User.find(params[:id])
    else
      @user = User.find(current_user.id)
    end
    
    #prune_database_records(@user) # there's gotta be a better way to do this... a way based on time
    
    @sales = @user.sales
    
    redirect_to "/admin_pages/home" if !current_user.nil? and current_user.has_role? :downloader
  end
  
  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user], :as => :admin)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end
  
  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end
  
  
  # I've never seen this pattern before, but we're going to delete old purchases that have been created but not paid for
  # this prevents a financial fraud where 'investors' inniciate purchases, wait for inflation to rais, then pay for their purchases
  # decades after they've been initiated.  It also helps me track the number of books I still have...
  # This is really stupid to have in a show dialogue... there are literally countless SQL queries occuring on the user show page...
  def prune_old_unpaid_purchase_records(user)
    user.sales.each do |sale|
      age_of_sale = ( (Time.now - sale.created_at) / 24 / 60 / 60 )
      sale.delete if (!sale.receipt_confirmed and !@sale.technically_paid?) and age_of_sale > 7.0
    end
  end
end