class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def authorize_user!
    authorize! params[:action], current_user, :message => 'Not authorized as an administrator.'
  end
  
  def downloaders_allowed!
    authorize! :download, :purchase_data
  end
  
  def team_members_only!
    authenticate_user! if current_user.nil?
    
    unless current_user.team_member?
      authorize! params[:action], current_user, :message => 'Not authorized as an administrator.'
    end
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  
  def after_sign_in_path_for(resource)
    #'/'
    current_user
  end
  
end
