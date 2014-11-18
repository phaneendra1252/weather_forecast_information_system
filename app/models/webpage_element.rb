class WebpageElement < ActiveRecord::Base
  belongs_to :website_url
  belongs_to :parameter
end
