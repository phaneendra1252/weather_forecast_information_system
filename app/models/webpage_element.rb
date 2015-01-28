class WebpageElement < ActiveRecord::Base
  has_many :website_urls, through: :webpage_elements_website_urls
  has_many :webpage_elements_website_urls
  validates :content_path, presence: true

  def content_path_value
    content_path_details[0]
  end

  def data_path_value
    content_path_details[1]
  end

  def content_path_details
    self.content_path.split(",").map(&:strip)
  end

end