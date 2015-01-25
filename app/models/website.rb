class Website < ActiveRecord::Base
  has_many :website_urls, :dependent => :destroy
  accepts_nested_attributes_for :website_urls, :allow_destroy => true
  validates :name, presence: true
end