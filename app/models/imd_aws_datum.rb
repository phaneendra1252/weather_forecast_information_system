require 'open-uri'
require 'spreadsheet'
class ImdAwsDatum < ActiveRecord::Base

	TABLE_HEADER = {
	  sr_no: "SR.NO.",
	  state_name: "STATE NAME",
	  station_name: "STATION NAME",
	  formated_parse_date: "DATE",
	  formated_time_utc: "TIME[UTC]",
	  formated_latitude_n: "LATITUDE[N]",
	  formated_longitude_e: "LONGITUDE[E]",
	  formated_slp_hpa: "SLP[hPa]",
	  formated_mslp_hpa: "MSLP",
	  formated_rainfall_mm: "RAINFALL[mm]",
	  formated_temperature_deg_c: "TEMPERATURE[Deg C]",
	  formated_dew_point_deg_c: "DEWPOINT[Deg C]",
	  formated_wind_speed_kt: "WINDSPEED[Kt]",
	  formated_wind_dir_deg: "WINDDIR[Deg]",
	  formated_tmax_deg_c: "TMAX[Deg C]",
	  formated_tmin_deg_c: "TMIN[Deg C]",
	  formated_ptend_hpa: "PTEND[hPa]",
	  formated_sshm: "SSHM"
	}
	ACTUAL_COLUMNS = [
		:sr_no, :state_id, :station_name, :parse_date, :time_utc,
		:latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm,
		:temperature_deg_c, :dew_point_deg_c, :wind_speed_kt, :wind_dir_deg,
		:tmax_deg_c, :tmin_deg_c, :ptend_hpa, :sshm
	]
	FLOAT_COLUMNS = [:latitude_n, :longitude_e, :slp_hpa, :mslp_hpa, :rainfall_mm, :temperature_deg_c, :dew_point_deg_c, :wind_speed_kt, :wind_dir_deg, :tmax_deg_c, :tmin_deg_c, :ptend_hpa, :sshm]
	COLUMN_VALUES = [:sr_no, :station_name, :parse_date, :time_utc] + FLOAT_COLUMNS

	belongs_to :imd_state

	validates :imd_state_id, presence: true

	def formated_parse_date
		self.parse_date.strftime("%e-%b-%Y")
	end

	def formated_time_utc
		self.time_utc.strftime("%H:%M:%S")
	end

	def state_name
		imd_state.name
	end

	FLOAT_COLUMNS.each do |float_column|
		method = "formated_"+float_column.to_s
		define_method(method) do
			value = self.send(float_column.to_s)
			if value.present?
				float_column.to_s == "mslp_hpa" ? value.prettify.to_s + " hpa" : value.prettify
			end
	  end
	end

	def self.test
		websites = Website.all
		websites.each do |website|
			website.website_urls.each do |website_url|
				url = ImdAwsDatum.replace_common_parameter_values(website_url, website_url.url)
				file_name = ImdAwsDatum.add_file_names(website_url, nil, website_url.webpage_elements.first.file_name)
				file_name = Rails.root.to_s + "/" + file_name+".xls"
				if File.exist?(file_name)
					book = Spreadsheet.open(file_name)
					File.delete(file_name)
				else
					book = Spreadsheet::Workbook.new
				end
				website_url.respective_parameter_groups.each do |respective_parameter_group|
					respective_url = ImdAwsDatum.replace_respective_parameter_values(website_url, respective_parameter_group, url)
					ImdAwsDatum.xls_generation(website_url, respective_parameter_group, respective_url, file_name, book)
				end
			end
		end
	end

	def self.replace_common_parameter_values(website_url, content)
		website_url.common_parameters.each do |common_parameter|
			content = content.gsub(common_parameter.symbol, common_parameter.value)
		end
		content
	end

	def self.replace_respective_parameter_values(website_url, respective_parameter_group, content)
		if respective_parameter_group.present?
			respective_parameter_group.respective_parameters.each do |respective_parameter|
				content = content.gsub(respective_parameter.symbol, respective_parameter.value)
			end
		end
		content
	end

	def self.add_file_names(website_url, respective_parameter_group, content)
		sheet_name = ImdAwsDatum.replace_common_parameter_values(website_url, content)
		sheet_name = ImdAwsDatum.replace_respective_parameter_values(website_url, respective_parameter_group, sheet_name)
	end

	def self.xls_generation(website_url, respective_parameter_group, url, file_name, book)
		url = File.open(url) #temp
		page = Nokogiri::HTML(url)
		website_url.webpage_elements.each do |webpage_element|
			sheet_name = ImdAwsDatum.add_file_names(website_url, respective_parameter_group, webpage_element.sheet_name)
			sheet = ImdAwsDatum.return_worksheet(book, sheet_name)
			sheet.row(0)[0] = page.css(webpage_element.heading_path).text
			page.css(webpage_element.content_path).each_with_index do |tr_data, tr_index|
				tr_data.css(webpage_element.data_path).each_with_index do |td_data, td_index|
					sheet.row(tr_index+1)[td_index] = td_data.text
				end
			end
			header = webpage_element.header
			if header.present?
				header = header.split("&&")
				header.each_with_index do |header_value, header_index|
					sheet.row(header_index+1).replace(header_value.split(",").map(&:strip))
				end
				merge_cells = webpage_element.merge_cells
				if merge_cells.present?
					merge_cells = merge_cells.split("&&")
					merge_cells.each do |merge_cell|
						r1, td1, r2, td2 = merge_cell.split(",").map(&:strip).map(&:to_i)
						sheet.merge_cells(r1, td1, r2, td2)
					end
				end
			end
			book.write file_name
		end
	end

	def self.return_worksheet(book, sheet_name)
		book.worksheets.each do |sheet|
			return sheet if (sheet.name == sheet_name)
		end
		return book.create_worksheet :name => sheet_name
	end

	def self.parse_imd_aws_data(from_date, to_date, imd_state_code)
		district_id = 0
		location_id = 0
		url = "file:///home/surya/project_files/WeatherAWSData.aspx.html"
		# url = "http://www.imdaws.com/WeatherAWSData.aspx?&FromDate=#{from_date}&ToDate=#{to_date}&State=#{imd_state_code}&District=#{district_id}&Loc=#{location_id}&Time="
		content_dom = "#DeviceData tr"
		inner_dom = "span"
		# page = Nokogiri::HTML(open(url))
		url = File.open("/home/surya/project_files/WeatherAWSData.aspx.html")
		page = Nokogiri::HTML(url)
		imd_state_id = ImdState.where(code: imd_state_code).first.id
		begin
			ActiveRecord::Base.transaction do
				page.css(content_dom)[1..-1].each do |tr_data|
					record_hash = { imd_state_id: imd_state_id }
					tr_data.css(inner_dom).each_with_index do |td_data, index|
						if COLUMN_VALUES[index].present?
							record_hash[COLUMN_VALUES[index]] = td_data.text
						end
					end
					imd_aws_record_data = ImdAwsDatum.strip_flat_value(record_hash)
					time_value = imd_aws_record_data[:parse_date] + " " + imd_aws_record_data[:time_utc]
					imd_aws_identification_records = imd_aws_record_data.select {|k,v| [:station_name, :time_utc].include?(k)}
					imd_aws_identification_records[:time_utc] = DateTime.parse(time_value)
					imd_aws_record_data[:time_utc] = imd_aws_identification_records[:time_utc]
					imd_aws_datum = ImdAwsDatum.where(imd_aws_identification_records).first
					imd_aws_record_data[:parse_date] = Date.parse(imd_aws_record_data[:parse_date])
					if imd_aws_datum.present?
						imd_aws_datum.update!(imd_aws_record_data)
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
		record_hash.each do |column, value|
			if FLOAT_COLUMNS.include?(column)
				record_hash[column] = value.scan(/-*[0-9,\.]+/).flatten.first
			end
		end
		record_hash
	end

end