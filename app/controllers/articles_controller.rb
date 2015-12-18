class ArticlesController < ApplicationController
  before_filter :set_title
  
  def index
    @title += "| Articles"
  end
  
  def unboxing
  end
  
  def op_democracy_distro
  end
  
  def encrypting_email
    @article_name = "Encrypting Emails"
    @title += "| #{@article_name}"
  end
  
  def bitcoin
    @article_name = "Buying with Bitcoin"
    @title += "| #{@article_name}"
  end
  
  def free_expression
    @article_name = "Might I Bring Your Attention to Free Expression?"
    @title += "| #{@article_name}"
  end
  
  def poemsec
    @title += "| PoemSec"
  end
  
  private
    def set_title
      @title = $HideBrand ? "Company Name " : "Anonymous Publications "
    end
end
