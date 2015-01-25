class WebsiteUrl < ActiveRecord::Base
  belongs_to :website
  has_many :parameters, :inverse_of => :website_url, :dependent => :destroy
  accepts_nested_attributes_for :parameters, :allow_destroy => true
  validates :website, presence: true
  validates :url, :uniqueness => true, presence: true

  has_many :webpage_elements, through: :webpage_elements_website_urls
  has_many :webpage_elements_website_urls
  accepts_nested_attributes_for :webpage_elements_website_urls, :allow_destroy => true

end