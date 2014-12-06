require 'open-uri'
class ImdAwsDatum < ActiveRecord::Base

	belongs_to :imd_state

	validates :imd_state_id, presence: true

	def state_name
		imd_state.name
	end

	def self.parse_imd_aws_data(from_date, to_date, state_id)
		district_id = 0
		location_id = 0
		url = "http://www.imdaws.com/WeatherAWSData.aspx?&FromDate=#{from_date}&ToDate=#{to_date}&State=#{state_id}&District=#{district_id}&Loc=#{location_id}&Time="
		content_dom = "#DeviceData tr"
		inner_dom = "span"
		columns = [:sr_no, :station_name, :parse_date, :time_utc, :latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c]
		page = Nokogiri::HTML(open(url))
		# transaction and include all columns   
		page.css(content_dom)[1..-1].each do |tr_data|
			record_hash = { imd_state_id: state_id }
			tr_data.css(inner_dom).each_with_index do |td_data, index|
				if columns[index].present?
					record_hash[columns[index]] = td_data.text
				end
			end
			ImdAwsDatum.create!(ImdAwsDatum.strip_flat_value(record_hash))
		end
	end

	def self.strip_flat_value(record_hash)
		float_columns = [:latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c]
		record_hash.each do |column, value|
			if float_columns.include?(column)
				record_hash[column] = value.scan(/(\d+[.]\d+)/).flatten.first
			end
		end
		record_hash
	end

end