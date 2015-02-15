class ImdAwsDatum < ActiveRecord::Base

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
		page = agent.get(url)
		webpage_element = website_url.webpage_element
		if group_by_element.blank?
			sheet_name = ImdAwsDatum.add_file_names(website_url, respective_parameter_group, webpage_element.sheet_name)
			sheet = ImdAwsDatum.return_worksheet(book, sheet_name)
			ImdAwsDatum.add_data_to_sheet(book, page, sheet, webpage_element, file_name)
		else
			ImdAwsDatum.group_by_sheet(page, webpage_element)
		end
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

end