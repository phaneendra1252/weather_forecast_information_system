class VisitParameter < ActiveRecord::Base
  belongs_to :visit
  validates :visit, presence: true
  validates :content_path, presence: true
  validates :data_path, presence: true
  validates :symbol, presence: true
  validates :data_type, presence: true
end