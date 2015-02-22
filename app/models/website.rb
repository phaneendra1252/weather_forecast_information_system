class Website < ActiveRecord::Base
  has_many :website_urls, :inverse_of => :website, :dependent => :destroy
  accepts_nested_attributes_for :website_urls, :allow_destroy => true
  validates :name, presence: true

  has_many :visits, :inverse_of => :website, :dependent => :destroy
  accepts_nested_attributes_for :visits, :allow_destroy => true

  def self.test
    websites = Website.all
    websites.each do |website|
      website.website_urls.each do |website_url|
        respective_parameter_groups = RespectiveParameterGroup.includes(:website_url).where('website_url_id = ?', website_url.id)
        respective_parameters = RespectiveParameter.includes(:respective_parameter_group).where('respective_parameter_group_id IN (?)', respective_parameter_groups.map(&:id))
        url = Website.replace_common_parameter_values(website_url, website_url.url)
        agent = Website.visit_task(website_url, respective_parameters)
        respective_parameter_groups = RespectiveParameterGroup.includes(:website_url).where('website_url_id = ?', website_url.id)
        if respective_parameter_groups.present?
          respective_parameter_groups.each do |respective_parameter_group|
            respective_parameters = RespectiveParameter.includes(:respective_parameter_group).where('respective_parameter_group_id = ?', respective_parameter_group.id)
            file_name = Website.add_file_names(website_url, respective_parameters, website_url.webpage_element.file_name)
            file_name = Website.return_file_path(file_name)
            book = Website.return_workbook(file_name)
            respective_url = Website.replace_respective_parameter_values(url, respective_parameters)
            Website.xls_generation(website_url, respective_parameters, respective_url, file_name, book, agent, nil)
          end
        else
          webpage_element = website_url.webpage_element
          file_name = Website.return_file_name(webpage_element)
          file_name = Website.return_file_path(file_name)
          book = Website.return_workbook(file_name)
          Website.xls_generation(website_url, nil, url, file_name, book, agent, webpage_element.group_by_element)
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
      file_name = file_name.titleize.gsub(" ", "-").gsub("/", "-")
      file_path = Setting.find_by(key: "file_path")
      if file_path.present?
        return file_path.value + "/" + file_name+".xlsx"
      end
    end
  end

  def self.return_file_name(webpage_element)
    return webpage_element.file_name
  end

  def self.visit_task(website_url, respective_parameters)
    agent = Mechanize.new
    website = website_url.website
    website.visits.each do |visit|
      page = agent.get(visit.url)
      visit_parameters = VisitParameter.includes(:visit).where('visit_id = ?', visit.id)
      respective_visits = RespectiveVisit.includes(:visit).where('visit_id = ?', visit.id)
      generate_visit_params = {
        visit_parameters: visit_parameters,
        respective_visits: respective_visits,
        page: page,
        agent: agent,
        respective_parameters: respective_parameters
      }
      generate_visit_data = Website.generate_visit_data(generate_visit_params)
      visit_data = generate_visit_data[0]
      block_data = generate_visit_data[1]
      visit_parameter_url_record = generate_visit_data[2]
      if visit_parameter_url_record.blank? && visit_data.present?
        keys = visit_data.keys
        if keys.present?
          values_length = visit_data[keys.first].length
          values_length.times do |i|
            record = {}
            keys.each do |key|
              record.merge!({ key => visit_data[key][i] })
            end
            Website.create_respective_parameters(record, website_url)
          end
        end
      elsif block_data.present?
        symbols = visit.respective_visits.map(&:symbol) # hardcoded
        key_visit_parameter = visit_parameters.select {|visit_parameter| visit_parameter.visit_parameter_url.present? }.first
        value_visit_parameter = visit_parameters.select {|visit_parameter| visit_parameter.visit_parameter_url.blank? }.first
        block_data.each do |district_id, block_details|
          name_block = block_details.last
          block_details.first.each_with_index do |block, i|
            if block != visit_parameter_url_record.ignore_value
              visit_data_index = visit_data[key_visit_parameter.symbol].index(district_id)
              district_name = visit_data[value_visit_parameter.symbol][visit_data_index]
              block_id = block
              block_name = name_block[i]
              record = {
                key_visit_parameter.symbol => district_id,
                value_visit_parameter.symbol => district_name,
                symbols.first => block_id,
                symbols.last => block_name
              }
              Website.create_respective_parameters(record, website_url)
            end
          end
        end
      end
    end
    agent
  end

  def self.generate_visit_data(generate_visit_params)
    page = generate_visit_params[:page]
    visit_parameters = generate_visit_params[:visit_parameters]
    respective_visits = generate_visit_params[:respective_visits]
    agent = generate_visit_params[:agent]
    respective_parameters = generate_visit_params[:respective_parameters]
    options_parsing_flag = Website.parse_options_status(page, visit_parameters, respective_visits, respective_parameters)
    generated_data = []
    if options_parsing_flag
      return_visit_data_and_url_record = Website.return_visit_data_and_url_record(page, visit_parameters)
      visit_data = return_visit_data_and_url_record[0]
      visit_parameter_url_record = return_visit_data_and_url_record[1]
      return_block_data_params = {
        respective_visits: respective_visits,
        agent: agent,
        visit_parameter_url_record: visit_parameter_url_record,
        visit_data: visit_data
      }
      block_data = Website.return_block_data(return_block_data_params)
      generated_data = [visit_data, block_data, visit_parameter_url_record]
    end
    return generated_data
  end

  def self.return_visit_data_and_url_record(page, visit_parameters)
    visit_data = {}
    visit_parameter_url_record = nil
    visit_parameters.each do |visit_parameter|
      visit_parameter_url_record = visit_parameter if visit_parameter.visit_parameter_url.present?
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
    return [visit_data, visit_parameter_url_record]
  end

  def self.return_block_data(return_block_data_params)
    agent = return_block_data_params[:agent]
    visit_parameter_url_record = return_block_data_params[:visit_parameter_url_record]
    visit_data = return_block_data_params[:visit_data]
    respective_visits = return_block_data_params[:respective_visits]
    block_data = {}
    if visit_parameter_url_record.present?
      keys = visit_data[visit_parameter_url_record.symbol]
      if keys.present?
        keys.each do |key|
          if key.to_s != visit_parameter_url_record.ignore_value
            url = visit_parameter_url_record.visit_parameter_url.gsub(visit_parameter_url_record.symbol, key.to_s)
            page = agent.get(url)
            block_data[key] ||= []
            respective_visits.each do |respective_visit|
              page.search(respective_visit.content_path).each_with_index do |tr_data, tr_index|
                temp = []
                tr_data.search(respective_visit.data_path).each_with_index do |td_data, td_index|
                  if respective_visit.data_type == "text"
                    temp << td_data.text
                  else
                    temp << td_data.attr(respective_visit.data_type)
                  end
                end
                block_data[key] << temp
              end
            end
          end
        end
      end
    end
    return block_data
  end

  def self.parse_options_status(page, visit_parameters, respective_visits, respective_parameters)
    visit_parameters.each do |object|
      return true if Website.check_records_status(object, page, respective_parameters)
    end
    respective_visits.each do |object|
      return true if Website.check_records_status(object, page, respective_parameters)
    end
    return false
  end

  def self.check_records_status(object, page, respective_parameters)
    if object.data_type == "text"
      options = page.search(object.content_path).search(object.data_path).map(&:text)
    else
      options = page.search(object.content_path).search(object.data_path).map{|option_value| option_value.attr(object.data_type) }
    end
    options = options - [object.ignore_value]
    values = []
    appropriate_respective_parameters = nil
    if respective_parameters.present?
      appropriate_respective_parameters = respective_parameters.select { |respective_parameter| respective_parameter.symbol == object.symbol }
      values = appropriate_respective_parameters.map(&:value).compact.uniq if appropriate_respective_parameters.present?
    end
    return (options - values).present?
  end

  def self.create_respective_parameters(record, website_url)
    # ActiveRecord::Base.transaction do
      flag = true
      respective_parameter_groups = website_url.respective_parameter_groups
      if respective_parameter_groups.present?
        respective_parameter_groups.each do |respective_parameter_group|
          respective_parameters = respective_parameter_group.respective_parameters
          record_parameters = []
          record.each do |key, value|
            record_parameter = respective_parameters.find_by(symbol: key, value: value)
            record_parameters << record_parameter if record_parameter.present?
          end
          if record_parameters.map(&:id) == respective_parameters.map(&:id)
            flag = false
            break
          end
        end
      end
      if flag
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

  def self.replace_common_parameter_values(website_url, content)
    common_parameters = CommonParameter.includes(:website_url).where('website_url_id = ?', website_url.id)
    common_parameters.each do |common_parameter|
      value = CommonParameter.add_date(common_parameter.value)
      content = content.gsub(common_parameter.symbol, value)
    end
    content
  end

  def self.replace_respective_parameter_values(content, respective_parameters)
    if respective_parameters.present?
      respective_parameters.each do |respective_parameter|
        value = CommonParameter.add_date(respective_parameter.value)
        content = content.gsub(respective_parameter.symbol, value)
      end
    end
    content
  end

  def self.add_file_names(website_url, respective_parameters, content)
    sheet_name = Website.replace_common_parameter_values(website_url, content)
    sheet_name = Website.replace_respective_parameter_values(sheet_name, respective_parameters)
    sheet_name = CommonParameter.add_date(sheet_name)
    sheet_name.gsub("/", "-")
  end

  def self.group_by_sheet(page, webpage_element)
    data = page.search(webpage_element.content_path)
    group_by_element = webpage_element.group_by_element
    data_path = webpage_element.data_path
    sheet_name = webpage_element.sheet_name
    index = Website.find_index_of_column(data, data_path, group_by_element)
    generated_data = Website.generate_data_from_webpage(data, index, data_path, group_by_element)
    collection_data, header_length = generated_data[0], generated_data[1]
    Website.create_excel_sheet_with_generated_data(collection_data, group_by_element, sheet_name, page, webpage_element, header_length)
  end

  def self.create_excel_sheet_with_generated_data(collection_data, group_by_element, sheet_name, page, webpage_element, header_length)
    collection_data.each do |k, v|
      if k != group_by_element
        file_name = Website.return_file_path(k)
        book = Website.return_workbook(file_name)
        sheet = Website.return_worksheet(book, sheet_name)
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

  def self.generate_data_from_webpage(data, index, data_path, group_by_element)
    collection_data = {}
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
    return [collection_data, header_length]
  end

  def self.find_index_of_column(data, data_path, group_by_element)
    index = nil
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
    return index
  end

  def self.xls_generation(website_url, respective_parameters, url, file_name, book, agent, group_by_element)
    page = agent.get(url)
    webpage_element = website_url.webpage_element
    if group_by_element.blank?
      sheet_name = Website.add_file_names(website_url, respective_parameters, webpage_element.sheet_name)
      sheet = Website.return_worksheet(book, sheet_name)
      Website.add_data_to_sheet(book, page, sheet, webpage_element, file_name)
    else
      Website.group_by_sheet(page, webpage_element)
    end
  end

  def self.generate_header(page, sheet, webpage_element)
    table_rows = page.search(webpage_element.header)
    header_length = table_rows.length
    spans_count = Website.spans_count(table_rows)
    spans_count.times do |t|
      if Website.spans_count(table_rows) > 0
        table_rows = Website.substitute_td_for_span(table_rows)
      else
        break
      end
    end
    table_rows.each_with_index do |tr_data, tr_index|
      tr_data.search(webpage_element.data_path).each_with_index do |td_data, td_index|
        sheet.add_cell(tr_index + 1, td_index, td_data.text)
      end
    end
    return header_length
  end

  def self.add_data_to_sheet(book, page, sheet, webpage_element, file_name)
    sheet.add_cell(0, 0, page.at(webpage_element.heading_path).text) if webpage_element.heading_path.present?
    header_length = Website.generate_header(page, sheet, webpage_element)
    page.search(webpage_element.content_path).each_with_index do |tr_data, tr_index|
      tr_data.search(webpage_element.data_path).each_with_index do |td_data, td_index|
        sheet.add_cell(header_length + tr_index+1, td_index, td_data.text)
      end
    end
    book.write file_name
  end

  def self.return_worksheet(book, sheet_name)
    sheet_name = CommonParameter.add_date(sheet_name)
    sheet = book[sheet_name]
    if sheet.blank?
      sheet_name = sheet_name.gsub("/", "-")
      sheet = book[sheet_name]
      if sheet.blank?
        sheet = book.add_worksheet(sheet_name)
      end
    end
    return sheet
  end

  def self.spans_count(table_rows)
    colspan_count = table_rows.text.count("colspan")
    rowspan_count = table_rows.text.count("rowspan")
    spans_count = (rowspan_count+colspan_count)
  end

  def self.substitute_td_for_span(table_rows)
    flag = false
    table_rows.each_with_index do |tr_data, tr_index|
      tr_data.search("td").each_with_index do |td_data, td_index|
        if td_data["rowspan"].present?
          (td_data["rowspan"].to_i - 1).times do |time|
            table_rows[tr_index+ time +1].search("td")[td_index].before("<td></td>")
          end
          td_data.remove_attribute("rowspan")
        end
        if td_data["colspan"].present?
          colspan_length = td_data["colspan"].to_i - 1
          (td_data["colspan"].to_i - 1).times do |time|
            table_rows[tr_index].search("td")[td_index+ time].after("<td></td>")
          end
          td_data.remove_attribute("colspan")
          flag = true
        end
        break if flag
      end
      break if flag
    end
    return table_rows
  end
end