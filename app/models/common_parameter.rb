class CommonParameter < ActiveRecord::Base
  belongs_to :website_url
  validates :symbol, presence: true
  validates :symbol, :uniqueness => { :scope => :website_url_id }
  #todo3 not working
  validates :website_url, presence: true
  validate :check_symbol_in_url

  def check_symbol_in_url
    webpage_element = self.website_url.webpage_element
    if self.website_url.url.index(symbol).blank? && webpage_element.file_name.index(symbol).blank? && webpage_element.sheet_name.index(symbol).blank?
      errors.add(:symbol, " doesn't exist in website url or file_name or sheet_name")
    end
  end

  def self.add_date(value)
    v = value
    if v.present?
      v = v.split(",")
      if v[0].present? && v[0].index("today").present?
        v = v.map(&:strip)
        return (Date.today + v[1].to_i).strftime(v[2])
      end
    end
    value
  end

end