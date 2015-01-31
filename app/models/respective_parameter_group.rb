class RespectiveParameterGroup < ActiveRecord::Base
  belongs_to :website_url
  has_many :respective_parameters, :inverse_of => :respective_parameter_group, :dependent => :destroy
  accepts_nested_attributes_for :respective_parameters, :allow_destroy => true
end