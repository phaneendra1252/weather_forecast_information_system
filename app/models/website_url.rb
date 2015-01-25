class WebsiteUrl < ActiveRecord::Base
  belongs_to :website
  has_many :parameters, :inverse_of => :website_url, :dependent => :destroy
  accepts_nested_attributes_for :parameters, :allow_destroy => true
  validates :website_id, presence: true
  validates :url, :uniqueness => true, presence: true
end