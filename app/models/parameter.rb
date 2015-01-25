class Parameter < ActiveRecord::Base
  belongs_to :website_url
  validates :symbol, presence: true
  validates :symbol, :uniqueness => { :scope => :website_url_id }
  validates :website_url, presence: true
  validate :check_symbol_in_url

  def check_symbol_in_url
    if self.website_url.url.index(symbol).blank?
      errors.add(:symbol, " doesn't exist in website url")
    end
  end
end