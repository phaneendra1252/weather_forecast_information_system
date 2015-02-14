class RespectiveParameter < ActiveRecord::Base
  belongs_to :respective_parameter_group
  # validates :respective_parameter_group, presence: true
  before_save :destruct_object

  def destruct_object
    if respective_parameter_group_id.blank?
      return false
    end
  end
end