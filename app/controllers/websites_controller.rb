class WebsitesController < ApplicationController
  before_action :set_website, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @websites = Website.all
    respond_with(@websites)
  end

  def show
    respond_with(@website)
  end

  def new
    @website = Website.new
    website_url = @website.website_urls.build
    website_url.parameters.build
    webpage_elements_website_url = website_url.webpage_elements_website_urls.build
    webpage_elements_website_url.build_webpage_element
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
      params.require(:website).permit(
        :name,
        :_destroy,
        website_urls_attributes: [
          :id,
          :_destroy,
          :url,
          parameters_attributes: [
            :id,
            :_destroy,
            :website_url_id,
            :symbol,
            :value
          ],
          webpage_elements_website_urls_attributes: [
            :id,
            :_destroy,
            :file_name,
            webpage_element_attributes: [
              :id,
              :_destroy,
              :heading_path,
              :content_path,
              :header
            ]
          ]
        ]
      )
    end
end