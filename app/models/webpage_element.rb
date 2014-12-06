class WebpageElement < ActiveRecord::Base
  belongs_to :website_url
  belongs_to :parameter


  def self.parse_data
  end

end
