class ImdState < ActiveRecord::Base

	has_many :imd_aws_data

	validates :name, :code, presence: true, uniqueness: true

end