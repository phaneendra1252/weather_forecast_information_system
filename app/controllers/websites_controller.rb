class WebsitesController < ApplicationController
  before_action :set_website, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @websites = Website.all
    @websites = Kaminari.paginate_array(@websites).page(params[:page]).per(10)
    respond_with(@websites)
  end

  def show
    respond_with(@website)
  end

  def new
    @website = Website.new
    website_url = @website.website_urls.build
    website_url.webpage_elements.build
    respond_with(@website)
  end

  def edit
  end

  def create
    @website = Website.new(website_params)
    @website.save
    respond_with(@website)
  end

  def update
    @website.update(website_params)
    respond_with(@website)
  end

  def destroy
    @website.destroy
    respond_with(@website)
  end

  private
    def set_website
      @website = Website.find(params[:id])
    end

    def website_params
      params.require(:website).permit(:name, :_destroy, website_urls_attributes: [:id, :_destroy, :url, webpage_elements_attributes: [:id, :_destroy, :parameter_id, :dom_path]])
    end
end
