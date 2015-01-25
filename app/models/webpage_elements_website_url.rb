class WebpageElementsWebsiteUrl < ActiveRecord::Base
  belongs_to :website_url
  belongs_to :webpage_element
  accepts_nested_attributes_for :webpage_element, :allow_destroy => true
  # validates :file_name, :uniqueness => { :scope => :website_url_id }
  # todo1
end