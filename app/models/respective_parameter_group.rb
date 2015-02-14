class RespectiveParameterGroup < ActiveRecord::Base
  belongs_to :website_url
  has_many :respective_parameters, :inverse_of => :respective_parameter_group, :dependent => :destroy
  accepts_nested_attributes_for :respective_parameters, :allow_destroy => true

  before_save :destruct_object

  def destruct_object
    visits = website_url.website.visits
    visits.each do |visit|
      visit.visit_parameters.each do |visit_parameter|
        if visit_parameter.ignore_value.present?
          self.respective_parameters.each do |respective_parameter|
            if (respective_parameter.symbol == visit_parameter.symbol) && (respective_parameter.value == visit_parameter.ignore_value)
              return false
            end
          end
        end
      end
    end
  end

end