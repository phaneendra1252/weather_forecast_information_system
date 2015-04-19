class ParsedUrlsController < ApplicationController
  before_action :set_parsed_url, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @parsed_urls = ParsedUrl.all
    respond_with(@parsed_urls)
  end

  def show
    respond_with(@parsed_url)
  end

  def new
    @parsed_url = ParsedUrl.new
    respond_with(@parsed_url)
  end

  def edit
  end

  def create
    @parsed_url = ParsedUrl.new(parsed_url_params)
    @parsed_url.save
    respond_with(@parsed_url)
  end

  def update
    @parsed_url.update(parsed_url_params)
    respond_with(@parsed_url)
  end

  def destroy
    @parsed_url.destroy
    respond_with(@parsed_url)
  end


  def download
    website = ParsedUrl.find(params[:parsed_url_id]).website
    bucket = Website.s3_configuration
    path = Website.return_folder_path(website)
    source_file = path + ".zip"
    key = source_file.split("tmp/").last
    object = bucket.objects[key]
    destination_file = source_file.split("/").last
    destination_file = "#{Rails.root}/tmp/#{destination_file}"
    if object.exists?
      File.open(destination_file, 'wb') do |file|
        object.read do |chunk|
          file.write(chunk)
        end
      end
    end
    send_file destination_file, :type=>"application/zip"
  end

  private
    def set_parsed_url
      @parsed_url = ParsedUrl.find(params[:id])
    end

    def parsed_url_params
      params.require(:parsed_url).permit(:date, :website_id, :string, :url)
    end
end
