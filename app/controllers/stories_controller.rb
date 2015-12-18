class StoriesController < ApplicationController
  before_filter :team_members_only!
  
  # shared... TODu... make these seperate pages for two roles, downloader and mailer???
  # Shipping
  skip_before_filter :team_members_only!, only: [:show, :index]
  
  before_filter :set_story, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @title = "Anonymous Publications | Latest News"
    @stories = Story.all
    respond_with(@stories)
  end

  def show
    @title = @story.header
    
    respond_with(@story)
  end

  def new
    @story = Story.new
    respond_with(@story)
  end

  def edit
  end

  def create
    @story = Story.new(params[:story])
    @story.save
    respond_with(@story)
  end

  def update
    @story.update_attributes(params[:story])
    respond_with(@story)
  end

  def destroy
    @story.destroy
    respond_with(@story)
  end

  private
    def set_story
      @story = Story.find(params[:id])
    end
end
