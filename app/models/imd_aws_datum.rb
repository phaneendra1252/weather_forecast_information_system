require 'open-uri'
class ImdAwsDatum < ActiveRecord::Base

	belongs_to :imd_state

	validates :imd_state_id, presence: true

	def state_name
		imd_state.name
	end

	def self.parse_imd_aws_data(from_date, to_date, imd_state_code)
		district_id = 0
		location_id = 0
		url = "file:///home/surya/project_files/WeatherAWSData.aspx.html"
		# url = "http://www.imdaws.com/WeatherAWSData.aspx?&FromDate=#{from_date}&ToDate=#{to_date}&State=#{imd_state_code}&District=#{district_id}&Loc=#{location_id}&Time="
		content_dom = "#DeviceData tr"
		inner_dom = "span"
		columns = [:sr_no, :station_name, :parse_date, :time_utc, :latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c, :dew_point_deg_c, :wind_speed_kt, :wind_dir_deg, :tmax_deg_c, :tmin_deg_c, :ptend_hpa, :sshm]
		# page = Nokogiri::HTML(open(url))
		url = File.open("/home/surya/project_files/WeatherAWSData.aspx.html")
		page = Nokogiri::HTML(url)
		imd_state_id = ImdState.where(code: imd_state_code).first.id
		begin
			ActiveRecord::Base.transaction do
				page.css(content_dom)[1..-1].each do |tr_data|
					record_hash = { imd_state_id: imd_state_id }
					tr_data.css(inner_dom).each_with_index do |td_data, index|
						if columns[index].present?
							record_hash[columns[index]] = td_data.text
						end
					end
					imd_aws_record_data = ImdAwsDatum.strip_flat_value(record_hash)
					imd_aws_identification_records = imd_aws_record_data.select {|k,v| [:sr_no, :station_name, :parse_date, :time_utc].include?(k)}
					imd_aws_datum = ImdAwsDatum.where(imd_aws_identification_records)
					if imd_aws_datum.present?
						imd_aws_datum.update_attributes!(imd_aws_record_data)
					else
						ImdAwsDatum.create!(imd_aws_record_data)
					end
				end
			end
			return { status: true }
		rescue Exception => e
			return { status: false, error_messages: e.message }
		end
	end

	def self.strip_flat_value(record_hash)
		float_columns = [:latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c, :dew_point_deg_c, :wind_speed_kt, :wind_dir_deg, :tmax_deg_c, :tmin_deg_c, :ptend_hpa, :sshm]
		record_hash.each do |column, value|
			if float_columns.include?(column)
				record_hash[column] = value.scan(/-*[0-9,\.]+/).flatten.first
			end
		end
		record_hash
	end

end