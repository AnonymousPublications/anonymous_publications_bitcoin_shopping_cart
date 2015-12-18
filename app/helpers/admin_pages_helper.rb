module AdminPagesHelper
  def more_info(info)
    render :partial => "/shared/more_info", :locals => { :info => info }
  end
end
