class WebpageElement < ActiveRecord::Base
  # has_many :website_urls, through: :webpage_elements_website_urls
  # has_many :webpage_elements_website_urls
  belongs_to :website_url
  validates :content_path, presence: true
end