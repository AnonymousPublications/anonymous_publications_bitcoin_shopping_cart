class PagesController < ApplicationController
  
  before_filter :set_title
  
  def home
    @title += ""
    redirect_to "/admin_pages/home" if !current_user.nil? and (current_user.has_role? :downloader or current_user.has_role? :shipping)
  end

  def about
    @title += "| About"
  end

  def careers
    @title += "| Careers"
  end

  def titles
    @title += "| Titles"
  end
  
  def purchasing
  end
  
  def blank
    render :layout => false
  end
  
  def pricing
	end

  def faq
	end

	def most_lovely
	end
	
	def donate
	end
	
	def mktg
	end
	
	def latest
	  
	  @stories = Story.all
	end
	
	def ows
	  @title += "| Occupy Wall Street"
	end

  def bookstores
    @title += "| Book Stores"
    @bookstores = Retailer.all
  end
  
  def secure
    @title += "| Secure"
  end
  
  # This is so we don't need to rely on google for content at all, much safer
  def css
    render file: "pages/css", content_type: Mime::CSS, layout: false
  end
  
  private
    def set_title
      @title = $HideBrand ? "Company Name " : "Anonymous Publications "
    end
    
end
