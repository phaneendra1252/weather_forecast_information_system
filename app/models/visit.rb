class Visit < ActiveRecord::Base
  belongs_to :website

  has_many :visit_parameters, :inverse_of => :visit, :dependent => :destroy
  accepts_nested_attributes_for :visit_parameters, :allow_destroy => true

  has_many :respective_visits, :inverse_of => :visit, :dependent => :destroy
  accepts_nested_attributes_for :respective_visits, :allow_destroy => true

  validates :website, presence: true
  validates :url, presence: true
end
