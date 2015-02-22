class RespectiveVisit < ActiveRecord::Base
  belongs_to :visit
  validates :visit, presence: true
end