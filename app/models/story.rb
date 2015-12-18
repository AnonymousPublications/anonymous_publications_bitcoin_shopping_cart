class Story < ActiveRecord::Base
  attr_accessible :author, :body, :date, :header, :img
  default_scope order('created_at DESC')
  
  def thumb_image_path
    (img.nil? or img.empty?) ? "/images/anon-logo_i.png" : img
  end
  
end
