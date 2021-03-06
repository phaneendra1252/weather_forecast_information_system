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
    build_objects
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

  def parse_websites
    if params[:websites].present?
      Website.delay.parse_wfis(params[:websites].map(&:to_i).compact)
      redirect_to websites_url, :notice => "Parsed data successfully"
    end
  end

  private
    def set_website
      @website = Website.find(params[:id])
    end

    def build_objects
      website_url = @website.website_urls.build
      visit = @website.visits.build
      visit.visit_parameters.build
      visit.respective_visits.build
      website_url.common_parameters.build
      website_url.respective_parameter_groups.build.respective_parameters.build
      website_url.build_webpage_element
    end

    def website_params
      params.require(:website).permit(
        :name,
        :folder_path,
        :_destroy,
        visits_attributes: [
          :id,
          :_destroy,
          :url,
          visit_parameters_attributes: [
            :id,
            :_destroy,
            :content_path,
            :data_path,
            :symbol,
            :data_type,
            :ignore_value,
            :visit_parameter_url
          ],
          respective_visits_attributes: [
            :id,
            :_destroy,
            :visit_id,
            :content_path,
            :data_path,
            :symbol,
            :data_type,
            :ignore_value
          ]
        ],
        website_urls_attributes: [
          :id,
          :_destroy,
          :url,
          common_parameters_attributes: [
            :id,
            :_destroy,
            :website_url_id,
            :symbol,
            :value
          ],
          webpage_element_attributes: [
            :id,
            :_destroy,
            :website_url_id,
            :heading_path,
            :content_path,
            :content_loop_path,
            :data_path,
            :header_path,
            :folder_path,
            :file_name,
            :sheet_name,
            :group_by_element
          ],
          respective_parameter_groups_attributes: [
            :id,
            :_destroy,
            :website_url_id,
            respective_parameters_attributes: [
              :id,
              :_destroy,
              :website_url_id,
              :symbol,
              :value
            ]
          ]
        ]
      )
    end
end