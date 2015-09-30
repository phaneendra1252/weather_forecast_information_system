require 'google/api_client'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'

API_VERSION = 'v2'
CACHED_API_FILE = ".google-fusiontables-#{API_VERSION}.cache"
CREDENTIAL_STORE_FILE = Rails.root.join('tmp', 'google_api_credentials.json')
CLIENT_SECRETS_FILE = Rails.root.join('tmp', 'client_secrets.json')

class Website < ActiveRecord::Base
  has_many :website_urls, :inverse_of => :website, :dependent => :destroy
  accepts_nested_attributes_for :website_urls, :allow_destroy => true
  validates :name, presence: true

  attr_accessor :parsed_websites, :attachments, :exception_errors, :backtrace_errors
  cattr_accessor :client, :drive

  has_many :visits, :inverse_of => :website, :dependent => :destroy
  accepts_nested_attributes_for :visits, :allow_destroy => true

  has_many :parsed_urls

  def self.set_google_drive_connection
    @@client = Google::APIClient.new(:application_name => 'fusion-tables-final',:application_version => '0.1.0')
    Website.create_credential_store_file
    Website.create_client_secrets_file
    file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
    if file_storage.authorization.nil?
      client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRETS_FILE)
      flow = Google::APIClient::InstalledAppFlow.new(
        :client_id => client_secrets.client_id,
        :client_secret => client_secrets.client_secret,
        :scope => ['https://www.googleapis.com/auth/drive']
      )
      @@client.authorization = flow.authorize(file_storage)
      Website.set_credential_record
    else
      @@client.authorization = file_storage.authorization
    end
    @@drive = @@client.discovered_api('drive', API_VERSION)
  end

  def self.create_client_secrets_file
    client_secrets_record = Setting.where(key: "client_secrets").first
    client_secrets_file = File.new(CLIENT_SECRETS_FILE, "w+")
    client_secrets_file.puts(client_secrets_record.value)
    client_secrets_file.close
  end

  def self.create_credential_store_file
    file_storage_record = Setting.where(key: "credential_store_file")
    if file_storage_record.present?
      credential_store_file = File.new(CREDENTIAL_STORE_FILE, "w+")
      credential_store_file.puts(file_storage_record.first.value)
      credential_store_file.close
    end
  end

  def self.set_credential_record
    credential_store_record = Setting.where(key: "credential_store_file").first_or_initialize
    credential_store_record.value = IO.read(CREDENTIAL_STORE_FILE)
    credential_store_record.save
  end

  def self.upload_files_to_google_drive(source_file_path, upload_file_title)
    result = @@client.execute(
      api_method: @@drive.files.list,
      parameters: {
        q: %(title = "#{upload_file_title}")
      }
    )
    existing_file = result.data['items'].first
    mime_type = 'application/octet-stream'
    media = Google::APIClient::UploadIO.new(source_file_path, mime_type)
    if existing_file.present?
      file = @@drive.files.update.request_schema.new({
        'title' => upload_file_title,
        'description' => upload_file_title,
        'mimeType' => mime_type
      })
      result = @@client.execute(
        :api_method => @@drive.files.update,
        :body_object => file,
        :media => media,
        :parameters => {
          'uploadType' => 'multipart',
          'fileId' => existing_file.id,
          'alt' => 'json'
        }
      )
    else
      file = @@drive.files.insert.request_schema.new({
        'title' => upload_file_title,
        'description' => upload_file_title,
        'mimeType' => mime_type
      })
      result = @@client.execute(
        :api_method => @@drive.files.insert,
        :body_object => file,
        :media => media,
        :parameters => {
          'uploadType' => 'multipart',
          'alt' => 'json'
        }
      )
    end
  end

  def self.download_files_from_google_drive(download_file_title, path, source_file)
    result = @@client.execute(
      api_method: @@drive.files.list,
      parameters: {
        q: %(title = "#{download_file_title}")
      }
    )
    file = result.data['items'].first
    if file.present?
      download_url = file['downloadUrl']
      result = @@client.execute(uri: download_url)
      IO.binwrite source_file, result.body
      Website.unzip(source_file, path, true)
    end
  end

  def report_mail_ids
    Setting.where(key: "report_mail_id").map(&:value)
  end

  def reports(websites)
    if websites.present?
      Report.where(website_name: websites.map(&:name))
    else
      Report.all
    end
  end

  def self.parse_wfis_website_by_website
    Website.all.each do |website|
      Website.parse_wfis(website.id)
    end
  end

  def self.clean_folder
    FileUtils.rm_rf("#{Rails.root}/tmp/#{(Date.today-1).strftime('%Y')}")
  end

  def self.parse_wfis(website_id = [])
    websites = []
    begin
    Website.set_google_drive_connection
    bucket = nil
    # websites = website_id.present? ? Website.find(website_id) : Website.all
    websites = website_id.present? ? Website.find([website_id].flatten) : Website.all
    notifications = {}
    attachments = []
    Website.clean_folder
    websites.each do |website|
      Website.download_from_s3_and_unzip(website, bucket)
      file_name = ""
      website_name = website.name
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
            file_name = Website.return_file_path(file_name, website_url.webpage_element, respective_parameters, website)
            book = Website.return_workbook(file_name)
            respective_url = Website.replace_respective_parameter_values(url, respective_parameters)
            Website.xls_generation(website_url, respective_parameters, respective_url, file_name, book, agent, nil, website)
          end
        else
          webpage_element = website_url.webpage_element
          file_name = Website.return_file_name(webpage_element)
          file_name = Website.return_file_path(file_name, webpage_element, respective_parameters, website)
          book = Website.return_workbook(file_name)
          Website.xls_generation(website_url, nil, url, file_name, book, agent, webpage_element.group_by_element, website)
        end
      end
      Website.zip_and_upload_on_s3(website, bucket)
      ###  hard coded
      bucket_url = "https://s3.amazonaws.com/wfisystem/"
      download_url_path = file_name.gsub("#{Rails.root}/tmp/", "")
      if download_url_path.index("xlsx")
        xlsx_file = download_url_path.split("/")[-1]
        download_url_path = download_url_path.gsub("/#{xlsx_file}", "") + ".zip"
        download_url_path = bucket_url + download_url_path
      end
      notifications.merge!({ website.name => download_url_path })
      attachments << Website.return_folder_path(website) + ".zip"
    end
    @website = Website.new
    @website.attachments = attachments
    notifications.each do |website_name, url|
      website = Website.where(name: website_name).first
      parsed_url = ParsedUrl.find_or_initialize_by(url: url)
      parsed_url.date = Date.today - 1
      parsed_url.website_id = website.id
      parsed_url.save
      @website.parsed_websites ||= []
      @website.parsed_websites << website_name
    end
    WebsiteMailer.send_notification(@website, websites).deliver
    # WebsiteMailer.send_notification(@website).deliver
    # attachments.each do |attachment|
    #   FileUtils.rm(attachment)
    # end
      # end
    rescue Exception => e
      @website = Website.new
      # @website.exception_errors = e.message
      @website.parsed_websites = websites.map(&:name)
      @website.exception_errors = e.message
      @website.backtrace_errors = e.backtrace
      WebsiteMailer.send_errors(@website).deliver
    end
  end

  def self.s3_configuration
    require 'aws-sdk'
    bucket_name = 'wfisystem'
    AWS.config(
      :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
    )
    s3 = AWS::S3.new
    bucket = s3.buckets[bucket_name]
    unless bucket.exists?
      bucket = s3.buckets.create(bucket_name)
    end
    return bucket
  end

  def self.zip_and_upload_on_s3(website, bucket)
    source_file_path = Website.zip_file(website)
    key = source_file_path.split("tmp/").last
    upload_file_title = Website.drive_file_name(key)
    Website.upload_files_to_google_drive(source_file_path, upload_file_title)
  end

  def self.drive_file_name(name)
    name.gsub('/', '_')
  end

  def self.zip_file(website)
    path = Website.return_folder_path(website)
    source_file_path = path + ".zip"
    Website.zip(path, source_file_path, true)
    return source_file_path
  end

  def self.download_from_s3_and_unzip(website, bucket)
    path = Website.return_folder_path(website)
    source_file = path + ".zip"
    key = source_file.split("tmp/").last
    folder_path = path.split("/")[0..-2].join("/")
    FileUtils.mkdir_p(folder_path)
    download_file_title = Website.drive_file_name(key)
    Website.download_files_from_google_drive(download_file_title, path, source_file)
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

  def self.zip(dir, zip_dir, remove_after = false)
    folder_name = dir.split("/").last.to_s
    require 'rubygems'
    require 'zip'
    require 'find'
    require 'fileutils'
    Zip::File.open(zip_dir, Zip::File::CREATE)do |zipfile|
      Find.find(dir) do |path|
        Find.prune if File.basename(path)[0] == ?.
        dest = /#{dir}\/(\w.*)/.match(path)
        # Skip files if they exists
        begin
# -          zipfile.add(dest[1],path) if dest
          if dest
            zipfile.add((folder_name + "/" + dest[1]),path)
          end
          # zipfile.add(dest[1],path) if dest
        rescue Zip::ZipEntryExistsError
        end
      end
    end
    FileUtils.rm_rf(dir) if remove_after
  end

  def self.unzip(zip, unzip_dir, remove_after = false)
    require 'rubygems'
    require 'zip'
    require 'find'
    require 'fileutils'
    Zip::File.open(zip) do |zip_file|
      zip_file.each do |f|
        # f_path=File.join(unzip_dir, f.name)
        f_path=File.join(unzip_dir.split("/")[0..-2].join("/"), f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
    FileUtils.rm(zip) if remove_after
  end

  def self.return_file_path(file_name, webpage_element, respective_parameters, website)
    if file_name.present?
      file_name = Website.add_file_names(webpage_element.website_url, respective_parameters, file_name)
      file_name = file_name.titleize.gsub(" ", "-").gsub("/", "-")
    end
    folder_path = Website.return_folder_path(website, webpage_element, respective_parameters)
    FileUtils::mkdir_p(folder_path)
    file_path = folder_path + "/" + file_name+".xlsx"
  end

  def self.return_folder_path(website, webpage_element = nil, respective_parameters = nil)
    folder_path = website.folder_path
    if folder_path.present?
      #hard coded
      # folder_path = folder_path.gsub("year", (Date.today-1).strftime("%Y"))
      # folder_path = folder_path.gsub("month", (Date.today-1).strftime("%B"))
      # folder_path = "/" + folder_path unless folder_path[0] == "/"
      # folder_path = "#{Rails.root}/tmp" + folder_path
      folder_path = Website.folder_path(folder_path)
      webpage_element_folder_path = webpage_element.folder_path if webpage_element.present?
      if webpage_element_folder_path.present?
        if webpage_element_folder_path[0] == "/"
          folder_path = folder_path + webpage_element_folder_path
        else
          folder_path = folder_path + "/" + webpage_element_folder_path
        end
      end
      if webpage_element.present?
        folder_path = Website.replace_matched_data(webpage_element.website_url, respective_parameters, folder_path)
      end
    end
    return folder_path
  end

  def self.folder_path(folder_path)
    folder_path = folder_path.gsub("year", (Date.today-1).strftime("%Y"))
    folder_path = folder_path.gsub("month", (Date.today-1).strftime("%B"))
    folder_path = folder_path.gsub("day", (Date.today-1).strftime("%d"))
    folder_path = "/" + folder_path unless folder_path[0] == "/"
    folder_path = "#{Rails.root}/tmp" + folder_path
    return folder_path
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
    Website.replace_matched_data(website_url, respective_parameters, content).gsub("/", "-")
  end

  def self.replace_matched_data(website_url, respective_parameters, content)
    sheet_name = Website.replace_common_parameter_values(website_url, content)
    sheet_name = Website.replace_respective_parameter_values(sheet_name, respective_parameters)
    sheet_name = CommonParameter.add_date(sheet_name)
  end

  def self.group_by_sheet(page, webpage_element, respective_parameters, website, website_url)
    table = page.search(webpage_element.content_path)
    header_data = table.search(webpage_element.header_path)
    data = table.search(webpage_element.content_loop_path)
    group_by_element = webpage_element.group_by_element
    data_path = webpage_element.data_path
    sheet_name = webpage_element.sheet_name
    index = Website.find_index_of_column(header_data, data_path, group_by_element)
    generated_data = Website.generate_data_from_webpage(data, index, data_path, group_by_element, header_data)
    collection_data, header_length = generated_data[0], generated_data[1]
    Website.create_excel_sheet_with_generated_data(collection_data, group_by_element, sheet_name, page, webpage_element, header_data, respective_parameters, website)
  end

  def self.create_excel_sheet_with_generated_data(collection_data, group_by_element, sheet_name, page, webpage_element, header_data, respective_parameters, website)
    collection_data.each do |k, v|
      file_name = Website.return_file_path(k, webpage_element, respective_parameters, website)
      book = Website.return_workbook(file_name)
      sheet = Website.return_worksheet(book, sheet_name)
      sheet.add_cell(0, 0, page.search(webpage_element.heading_path).text) if webpage_element.heading_path.present?
      header_length = Website.generate_header(page, sheet, webpage_element)
      v.each_with_index do |row, tr_index|
        row.each_with_index do |td_data, td_index|
          sheet.add_cell(tr_index+1+header_length, td_index, td_data.text)
        end
      end
      book.write file_name
      # pending
      Website.generate_report(website, sheet, file_name)
    end
  end

  def self.generate_data_from_webpage(data, index, data_path, group_by_element, header_data)
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
    header_length = 0
    return [collection_data, header_length]
  end

  def self.find_index_of_column(data, data_path, group_by_element)
    index = nil
    data.each do |trs|
      if index.blank?
        trs.search(data_path).each_with_index do |td, i|
          data = Website.strip_data(td.text)
          if index.blank? && data == group_by_element
            index = i
            break
          end
        end
      end
      break if index.present?
    end
    return index
  end

  def self.xls_generation(website_url, respective_parameters, url, file_name, book, agent, group_by_element, website)
    page = agent.get(url)
    webpage_element = website_url.webpage_element
    if group_by_element.blank?
      sheet_name = Website.add_file_names(website_url, respective_parameters, webpage_element.sheet_name)
      sheet = Website.return_worksheet(book, sheet_name)
      Website.add_data_to_sheet(book, page, sheet, webpage_element, file_name, website, website_url)
    else
      Website.group_by_sheet(page, webpage_element, respective_parameters, website, website_url)
    end
  end

  def self.generate_header(page, sheet, webpage_element)
    table = page.search(webpage_element.content_path)
    table_rows = table.search(webpage_element.header_path)
    header_length = table_rows.length
    spans_count = Website.spans_count(table_rows)
    spans_count.times do |t|
      if Website.spans_count(table_rows) > 0
        table_rows = Website.substitute_td_for_span(table_rows)
      else
        break
      end
    end
    sheet.change_row_bold(row = 0, bolded = true)
    table_rows.each_with_index do |tr_data, tr_index|
      sheet.change_row_bold(row = tr_index+1, bolded = true)
      # change rake task and change column names
      sheet.change_row_fill(row = tr_index+1, font_color = '00bfff')
      tr_data.search(webpage_element.data_path).each_with_index do |td_data, td_index|
        header_content_length = td_data.text.length
        content_column_data = page.search(webpage_element.content_path).search(webpage_element.content_loop_path).search(webpage_element.data_path+":nth-child(#{(td_index+1)})")
        content_column_length = 0
        if content_column_data.present?
          content_column_length = content_column_data.map(&:text).map(&:length).max
        end
        if content_column_length > header_content_length && content_column_length > sheet.get_column_width(td_index)
          sheet.change_column_width(td_index, content_column_length)
        elsif header_content_length > content_column_length && header_content_length > sheet.get_column_width(td_index)
          sheet.change_column_width(td_index, header_content_length)
        end
        data = Website.strip_data(td_data.text)
        sheet.add_cell(tr_index + 1, td_index, data)
      end
    end
    return header_length
  end

  def self.strip_data(data)
    return data.gsub("\302\240", ' ').gsub("\r\n", "").gsub("\t"," ").strip.squeeze(' ')
  end

  def self.testing
    agent = Mechanize.new
    page = agent.get("file:///home/surya/weather_forecast_information_system/dwr.doc")
    raise page.search("#DeviceData tr td:nth-child(2)").map(&:text).map(&:length).max.inspect
  end

  def self.generate_report(website, sheet, file_name)
    extract_data = sheet.extract_data
    website_name = website.name
    column_length = extract_data.compact.map(&:length).max
    row_length = extract_data.length
    date = Date.today - 1
# -    file_name = file_name.gsub("#{Rails.root}/tmp/", "")
    file_name = file_name.gsub("#{Rails.root}/tmp/", "").split("/")[3..-1]
    file_name = file_name.join("/")
    # file_name = file_name.gsub("#{Rails.root}/tmp/", "")
    report = Report.find_by(file_name: file_name)
    if report.blank?
      Report.create(
        website_name: website_name,
        file_name: file_name,
        yesterday_date: (date -1),
        today_date: date,
        yesterday_row_count: 0,
        today_row_count: row_length,
        row_count_difference: (row_length - 0),
        yesterday_column_count: 0,
        today_column_count: column_length,
        column_count_difference: (column_length - 0)
      )
    else
      if report.today_date != date
        report.yesterday_date = report.today_date
        report.yesterday_row_count = report.today_row_count
        report.yesterday_column_count = report.today_column_count
      end
      report.today_date = date
      report.today_row_count = row_length
      report.row_count_difference = (report.today_row_count - report.yesterday_row_count)
      report.today_column_count = column_length
      report.column_count_difference = (report.today_column_count - report.yesterday_column_count)
      report.save!
    end
    Website.add_data_to_report_sheet(website)
  end

  def self.add_data_to_report_sheet(website)
    folder_path = Website.return_folder_path(website)
    # folder_path = "/year/month"
    # folder_path = Website.folder_path(folder_path)
    website_name = website.name
    file_name = folder_path + "/" + "1_#{website_name}_report.xlsx"
    book = Website.return_workbook(file_name)
    sheet = Website.return_worksheet(book, (Date.today-1).to_s)
    sheet.add_cell(0, 0, "Weather Forecasting report")
    sheet.change_row_fill(row = 1, font_color = '00bfff')
    columns = [
                "website_name", "file_name", "yesterday_date", "today_date", "yesterday_row_count",
                "today_row_count", "row_count_difference", "yesterday_column_count", "today_column_count",
                "column_count_difference"
              ]
    header = columns.map(&:humanize)
    header.each_with_index do |h, i|
      sheet.add_cell(1, i, h)
      if h == "file_name".humanize
        sheet.change_column_width(i, 30)
      else
        sheet.change_column_width(i, h.length)
      end
    end
    reports = Report.where(website_name: website_name)
    reports.each_with_index do |report, index|
      columns.each_with_index do |column, column_index|
        if column == "file_name"
# -          cell = sheet.add_cell(index+2, column_index, report[column].split("/").last)
          striped_path = folder_path.gsub("#{Rails.root}/tmp/", "") + "/"
          striped_path = report[column].gsub(striped_path, "")
          cell = sheet.add_cell(index+2, column_index, striped_path)
          # cell = sheet.add_cell(index+2, column_index, report[column].split("/").last)
        else
          cell =sheet.add_cell(index+2, column_index, report[column])
        end
        if ["row_count_difference", "column_count_difference"].include?(column)
          if report[column] < 0
            cell.change_fill("ff0000")
          end
        end
      end
    end
    book.write file_name
  end

  def self.add_data_to_sheet(book, page, sheet, webpage_element, file_name, website, website_url)
    heading = ""
    table = page.search(webpage_element.content_path)
    if webpage_element.heading_path.present?
      heading = page.search(webpage_element.heading_path).text
      heading = Website.strip_data(heading)
    end
    sheet.add_cell(0, 0, heading)
    header_length = Website.generate_header(page, sheet, webpage_element)
    table.search(webpage_element.content_loop_path).each_with_index do |tr_data, tr_index|
      tr_data.search(webpage_element.data_path).each_with_index do |td_data, td_index|
        data = Website.strip_data(td_data.text)
        sheet.add_cell(header_length + tr_index+1, td_index, data)
      end
    end
    book.write file_name
    Website.generate_report(website, sheet, file_name)
  end

  def self.return_worksheet(book, sheet_name)
    sheet_name = CommonParameter.add_date(sheet_name)
    sheet = book[sheet_name]
    if sheet.blank?
      sheet_name = sheet_name.gsub("/", "-")
      sheet = book[sheet_name]
      if sheet.blank?
        sheet = book["Sheet1"]
        if sheet.present?
          sheet.sheet_name = sheet_name
        else
          sheet = book.add_worksheet(sheet_name)
        end
      end
    end
    sheet.delete_column
    sheet.merge_cells(0, 0, 0, 10)
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
            # temp fix check for permanet solution if no tr then what to do
            if table_rows[tr_index+ time +1].present?
              table_rows[tr_index+ time +1].search("td")[td_index].before("<td></td>")
            end
          end
          td_data.remove_attribute("rowspan")
        end
        if td_data["colspan"].present?
          colspan_length = td_data["colspan"].to_i - 1
          (td_data["colspan"].to_i - 1).times do |time|
            colspan_data = "<td>#{td_data.text}</td>"
            table_rows[tr_index].search("td")[td_index+ time].after(colspan_data)
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