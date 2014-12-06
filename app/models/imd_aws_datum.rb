class ImdAwsDatum < ActiveRecord::Base

	belongs_to :imd_state

	validates :imd_state_id, presence: true

	def state_name
		imd_state.name
	end

end