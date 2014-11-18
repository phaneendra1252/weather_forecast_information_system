class WebsiteUrl < ActiveRecord::Base
  belongs_to :website
  has_many :webpage_elements, :dependent => :destroy
  accepts_nested_attributes_for :webpage_elements, :reject_if => lambda { |a| a[:dom_path].blank? }, :allow_destroy => true
end
