require 'open-uri'
require 'spreadsheet'
require 'rubyXL'
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
				agent = ImdAwsDatum.visit_task(website_url)
				respective_parameter_groups = website_url.respective_parameter_groups
				if respective_parameter_groups.present?
					respective_parameter_groups.each do |respective_parameter_group|
						file_name = ImdAwsDatum.add_file_names(website_url, respective_parameter_group, website_url.webpage_element.file_name)
						file_name = ImdAwsDatum.return_file_path(file_name)
						book = ImdAwsDatum.return_workbook(file_name)
						respective_url = ImdAwsDatum.replace_respective_parameter_values(website_url, respective_parameter_group, url)
						ImdAwsDatum.xls_generation(website_url, respective_parameter_group, respective_url, file_name, book, agent, nil)
					end
				else
					webpage_element = website_url.webpage_element
					file_name = ImdAwsDatum.return_file_name(webpage_element)
					file_name = ImdAwsDatum.return_file_path(file_name)
					book = ImdAwsDatum.return_workbook(file_name)
					self.xls_generation(website_url, nil, url, file_name, book, agent, webpage_element.group_by_element)
				end
			end
		end
	end

	def self.return_workbook(file_name)
		if file_name.present?
			if File.exist?(file_name)
				book = RubyXL::Parser.parse(file_name)
			else
				book = RubyXL::Workbook.new
			end
			return book
		end
	end

	def self.return_file_path(file_name)
		if file_name.present?
			return Rails.root.to_s + "/" + file_name+".xlsx"
		end
	end

	def self.return_file_name(webpage_element)
		return webpage_element.file_name
	end

	def self.visit_task(website_url)
		agent = Mechanize.new
		website = website_url.website
		website.visits.each do |visit|
			page = agent.get(visit.url)
			visit_data = {}
			visit.visit_parameters.each do |visit_parameter|
				page.search(visit_parameter.content_path).each_with_index do |tr_data, tr_index|
					tr_data.search(visit_parameter.data_path).each_with_index do |td_data, td_index|
						visit_data[visit_parameter.symbol] ||= []
						if visit_parameter.data_type == "text"
							visit_data[visit_parameter.symbol] << td_data.text
						else
							visit_data[visit_parameter.symbol] << td_data.attr(visit_parameter.data_type)
						end
					end
				end
			end
			keys = visit_data.keys
			values_length = visit_data[keys.first].length
			values_length.times do |i|
				record = {}
				keys.each do |key|
					record.merge!({ key => visit_data[key][i] })
				end
				# ActiveRecord::Base.transaction do
					respective_parameter = nil
					respective_parameter_groups = website_url.respective_parameter_groups
					record.each do |key, value|
						if respective_parameter_groups.present?
							respective_parameter_groups.each do |respective_parameter_group|
								respective_parameter_group.respective_parameters.each do |rp|
									if rp.symbol == key && rp.value == value
										respective_parameter = rp
										break
									end
								end
							end
						end
					end
					if respective_parameter.blank?
						respective_parameter_group = respective_parameter_groups.new
						record.each do |k, v|
							respective_parameter = respective_parameter_group.respective_parameters.new
							respective_parameter.symbol = k
							respective_parameter.value = v
							respective_parameter.save
						end
					end
				# end
			end
		end
		agent
	end

	def self.replace_common_parameter_values(website_url, content)
		website_url.common_parameters.each do |common_parameter|
			value = CommonParameter.add_date(common_parameter.value)
			content = content.gsub(common_parameter.symbol, value)
		end
		content
	end

	def self.replace_respective_parameter_values(website_url, respective_parameter_group, content)
		if respective_parameter_group.present?
			respective_parameter_group.respective_parameters.each do |respective_parameter|
				value = CommonParameter.add_date(respective_parameter.value)
				content = content.gsub(respective_parameter.symbol, value)
			end
		end
		content
	end

	def self.add_file_names(website_url, respective_parameter_group, content)
		sheet_name = ImdAwsDatum.replace_common_parameter_values(website_url, content)
		sheet_name = ImdAwsDatum.replace_respective_parameter_values(website_url, respective_parameter_group, sheet_name)
		sheet_name.gsub("/", "-")
	end

	def self.group_by_sheet(page, webpage_element)
		data = page.search(webpage_element.content_path)
		group_by_element = webpage_element.group_by_element
		data_path = webpage_element.data_path
		sheet_name = webpage_element.sheet_name
		index = nil
		collection_data = {}
		data.each do |trs|
			if index.blank?
				trs.search(data_path).each_with_index do |td, i|
					if index.blank? && td.text.strip == group_by_element
						index = i
						break
					end
				end
			end
			break if index.present?
		end
		data.each do |trs|
			if index.present?
				td_search = trs.search(data_path)
				group_by_data = td_search[index]
				if group_by_data.present?
					if collection_data.keys.index(group_by_data.text).blank?
						collection_data.merge!({ group_by_data.text => [td_search] })
					else
						collection_data[group_by_data.text] << td_search
					end
				end
			end
		end
		if collection_data[group_by_element].present?
			header_length = collection_data[group_by_element].length
		else
			header_length = 0
		end
		collection_data.each do |k, v|
			if k != group_by_element
				file_name = ImdAwsDatum.return_file_path(k)
				book = ImdAwsDatum.return_workbook(file_name)
				sheet = ImdAwsDatum.return_worksheet(book, sheet_name)
				sheet.add_cell(0, 0, page.at(webpage_element.heading_path).text) if webpage_element.heading_path.present?
				collection_data[group_by_element].each_with_index do |header_row, header_index|
					header_row.each_with_index do |header_data, header_data_index|
						sheet.add_cell(header_index+1, header_data_index, header_data.text)
					end
				end
				v.each_with_index do |row, tr_index|
					row.each_with_index do |td_data, td_index|
						sheet.add_cell(tr_index+1+header_length, td_index, td_data.text)
					end
				end
				book.write file_name
			end
		end
	end

	def self.xls_generation(website_url, respective_parameter_group, url, file_name, book, agent, group_by_element)
		# page = agent.get(url)
		# webpage_element = website_url.webpage_element
		# if group_by_element.blank?
		# 	sheet_name = ImdAwsDatum.add_file_names(website_url, respective_parameter_group, webpage_element.sheet_name)
		# 	sheet = ImdAwsDatum.return_worksheet(book, sheet_name)
		# 	ImdAwsDatum.add_data_to_sheet(book, page, sheet, webpage_element, file_name)
		# else
		# 	ImdAwsDatum.group_by_sheet(page, webpage_element)
		# end
			# header = webpage_element.header
			# if header.present?
			# 	header = header.split("&&")
			# 	header.each_with_index do |header_value, header_index|
			# 		# sheet.row(header_index+1).replace(header_value.split(",").map(&:strip))
			# 		sheet.sheet_data[header_index+1][td_index].change_contents(td_data.text)
			# 	end
			# 	merge_cells = webpage_element.merge_cells
			# 	if merge_cells.present?
			# 		merge_cells = merge_cells.split("&&")
			# 		merge_cells.each do |merge_cell|
			# 			r1, td1, r2, td2 = merge_cell.split(",").map(&:strip).map(&:to_i)
			# 			sheet.merge_cells(r1, td1, r2, td2)
			# 		end
			# 	end
			# end
		# end
	end

	def self.add_data_to_sheet(book, page, sheet, webpage_element, file_name)
		sheet.add_cell(0, 0, page.at(webpage_element.heading_path).text) if webpage_element.heading_path.present?
		page.search(webpage_element.content_path).each_with_index do |tr_data, tr_index|
			tr_data.search(webpage_element.data_path).each_with_index do |td_data, td_index|
				sheet.add_cell(tr_index+1, td_index, td_data.text)
			end
		end
		book.write file_name
	end

	def self.return_worksheet(book, sheet_name)
		sheet = book[sheet_name]
		if sheet.blank?
			sheet_name = CommonParameter.add_date(sheet_name)
			sheet_name = sheet_name.gsub("/", "-")
			sheet = book[sheet_name]
			if sheet.blank?
				sheet = book.add_worksheet(sheet_name)
			end
		end
		return sheet
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