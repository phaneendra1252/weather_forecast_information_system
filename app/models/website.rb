class Website < ActiveRecord::Base
  has_many :website_urls, :dependent => :destroy
  accepts_nested_attributes_for :website_urls, :reject_if => lambda { |a| a[:url].blank? }, :allow_destroy => true
end
