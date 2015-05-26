admin_role = Role.where(name: "admin").first_or_create
moderator_role = Role.where(name: "moderator").first_or_create

if User.where(email: ENV['USER_EMAIL']).blank?
	user = User.new(name: "Surya", email: ENV['USER_EMAIL'], password: "testing123", password_confirmation: "testing123")
	user.role_ids = [admin_role.id, moderator_role.id]
	user.save
end

setting = Setting.where(key: "report_mail_id", value: ENV['USER_EMAIL']).first_or_initialize
setting.save

setting = Setting.where(key: "report_mail_id", value: ENV['ALTERNATIVE_USER_EMAIL']).first_or_initialize
setting.save

# apsdps start

website = Website.where(name: "apsdps").first_or_initialize
website.folder_path = "/year/month/day/apsdps"
website.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://apsdps.gov.in/soil_moisture.jsp").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "#dp_content_map1 table tr td:first"
webpage_element.content_path = "#dp_content_temp table"
webpage_element.content_loop_path = "tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr[1], tr[2]"
webpage_element.folder_path = "/ap_soil_moisture"
webpage_element.file_name = ""
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.group_by_element = "District"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://apsdps.gov.in/radiationtable.jsp").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = ""
webpage_element.content_path = "#dp_content_temp table"
webpage_element.content_loop_path = "tr:not(:nth-child(1))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr[1]"
webpage_element.folder_path = "/ap_radiation"
webpage_element.file_name = ""
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.group_by_element = "District"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://117.247.178.102/tsdps/soil_moisture.jsp").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "#dp_content_map1 table tr td:first"
webpage_element.content_path = "#dp_content_temp table"
webpage_element.content_loop_path = "tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr[1], tr[2]"
webpage_element.folder_path = "/ts_soil_moisture"
webpage_element.file_name = ""
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.group_by_element = "District"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://117.247.178.102/tsdps/radiationtable.jsp").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = ""
webpage_element.content_path = "#dp_content_temp table"
webpage_element.content_loop_path = "tr:not(:nth-child(1))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr[1]"
webpage_element.folder_path = "/ts_radiation"
webpage_element.file_name = ""
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.group_by_element = "District"
webpage_element.save

# apsdps end verified

# daily report start

website = Website.where(name: "daily_report").first_or_initialize
website.folder_path = "/year/month/day/daily_report"
website.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdmumbai.gov.in/scripts/latest.asp?releaseId=EWD").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "tr[1]"
webpage_element.content_path = "#mainTbl1 #inTable2 tr td div table[@bordercolor='white']:last"
webpage_element.content_loop_path = "tr:not(:nth-child(1)):not(:nth-child(2)):not(:nth-child(3)):not(:nth-last-child(1))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr[2], tr[3]"
webpage_element.folder_path = "/maharastra_imd_gov"
webpage_element.file_name = "maharastra_imd_gov"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdhyderabad.gov.in/apsite/apobs.html").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "tr:nth-child(1)"
webpage_element.content_path = "table"
webpage_element.content_loop_path = "tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr:nth-child(2)"
webpage_element.folder_path = "/andhra_pradesh_imd_gov"
webpage_element.file_name = "andhra_pradesh_imd_gov"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdhyderabad.gov.in/tssite/tlngobs.htm").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "tr:nth-child(1)"
webpage_element.content_path = "table"
webpage_element.content_loop_path = "tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr:nth-child(2)"
webpage_element.folder_path = "/telangana_imd_gov"
webpage_element.file_name = "telangana_imd_gov"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdchennai.gov.in/obs_data.htm").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "tr:nth-child(1)"
webpage_element.content_path = "#table1"
webpage_element.content_loop_path = "tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr:nth-child(2)"
webpage_element.folder_path = "/tamilnadu_imd_gov"
webpage_element.file_name = "tamilnadu_imd_gov"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdaws.com/WeatherAWSData.aspx?&FromDate=from_date&ToDate=to_date&State=state_id&District=0&Loc=0&Time=").first_or_create

common_parameter = CommonParameter.where(website_url_id: website_url.id, symbol: "from_date").first_or_initialize
common_parameter.value = "today, -1, %d/%m/%Y"
common_parameter.save

common_parameter = CommonParameter.where(website_url_id: website_url.id, symbol: "to_date").first_or_initialize
common_parameter.value = "today, -1, %d/%m/%Y"
common_parameter.save

respective_parameter_group = RespectiveParameterGroup.create(website_url_id: website_url.id)

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_name").first_or_initialize
respective_parameter.value = "ANDHRA PRADESH"
respective_parameter.save

respective_parameter =  respective_parameter_group.respective_parameters.where(symbol: "state_id").first_or_initialize
respective_parameter.value = "2"
respective_parameter.save

respective_parameter_group = RespectiveParameterGroup.create(website_url_id: website_url.id)

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_name").first_or_initialize
respective_parameter.value = "TELANGANA"
respective_parameter.save

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_id").first_or_initialize
respective_parameter.value = "51"
respective_parameter.save

respective_parameter_group = RespectiveParameterGroup.create(website_url_id: website_url.id)

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_name").first_or_initialize
respective_parameter.value = "GUJARAT"
respective_parameter.save

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_id").first_or_initialize
respective_parameter.value = "8"
respective_parameter.save

respective_parameter_group = RespectiveParameterGroup.create(website_url_id: website_url.id)

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_name").first_or_initialize
respective_parameter.value = "MAHARASHTRA"
respective_parameter.save

respective_parameter = respective_parameter_group.respective_parameters.where(symbol: "state_id").first_or_initialize
respective_parameter.value = "16"
respective_parameter.save

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = ""
webpage_element.content_path = "#DeviceData"
webpage_element.content_loop_path = "tr:not(:nth-child(1))"
webpage_element.data_path = "td"
webpage_element.header_path = "tr:nth-child(1)"
webpage_element.file_name = "state_name_imdaws"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

#daily report end last part to be corrected

# Tamilnadu data start
website = Website.where(name: "tamilnadu_data").first_or_initialize
website.folder_path = "/year/month/day/tamilnadu_data"
website.save
visit = Visit.where(website_id: website.id, url: "http://tawn.tnau.ac.in").first_or_create

visit = Visit.where(website_id: website.id, url: "http://tawn.tnau.ac.in/General/DistrictWiseSummaryPublicUI.aspx?RW=1").first_or_create

visit_parameter = VisitParameter.where(visit_id: visit.id, symbol: "district_id").first_or_initialize
visit_parameter.content_path = "select#ddlDistrict"
visit_parameter.data_path = "option"
visit_parameter.data_type = "value"
visit_parameter.ignore_value = "0"
visit_parameter.visit_parameter_url = "http://tawn.tnau.ac.in/General/BlockWiseSummaryPublicUI.aspx?EntityHierarchyOneKey=district_id&lang=en"
visit_parameter.save

visit_parameter = VisitParameter.where(visit_id: visit.id, symbol: "district_name").first_or_initialize
visit_parameter.content_path = "select#ddlDistrict"
visit_parameter.data_path = "option"
visit_parameter.data_type = "text"
visit_parameter.ignore_value = "-- All --"
visit_parameter.visit_parameter_url = ""
visit_parameter.save

respective_visit = RespectiveVisit.where(visit_id: visit.id, symbol: "block_id").first_or_initialize
respective_visit.content_path = "select#ddlBlock"
respective_visit.data_path = "option"
respective_visit.data_type = "value"
respective_visit.ignore_value = "0"
respective_visit.save

respective_visit = RespectiveVisit.where(visit_id: visit.id, symbol: "block_name").first_or_initialize
respective_visit.content_path = "select#ddlBlock"
respective_visit.data_path = "option"
respective_visit.data_type = "text"
respective_visit.ignore_value = "-- All --"
respective_visit.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://tawn.tnau.ac.in/General/BlockLastDayWeatherDataPublicUI.aspx?EntityHierarchyOneKey=district_id&EntityHierarchyTwoKey=block_id&lang=en").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = ""
webpage_element.content_path = ".TabbedPanelsContent .table1"
webpage_element.content_loop_path = "#DynamicWeatherDataDiv > div"
webpage_element.data_path = "div"
webpage_element.header_path = "#DynaicHeaderDiv > div"
# webpage_element.folder_path = "/year/month/tamilnadu_data"
webpage_element.file_name = "block_name"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

# Tamilnadu data end verified

# # Imdaws data start
# website = Website.where(name: "imd_aws").first_or_initialize
# website.folder_path = "/year/month/imd_aws"
# website.save
# visit = Visit.where(website_id: website.id, url: "http://www.imdaws.com/viewawsdata.aspx").first_or_create

# visit_parameter = VisitParameter.where(visit_id: visit.id, symbol: "state_id").first_or_initialize
# visit_parameter.content_path = "#CmbState"
# visit_parameter.data_path = "option"
# visit_parameter.data_type = "value"
# visit_parameter.ignore_value = "0"
# visit_parameter.save

# visit_parameter = VisitParameter.where(visit_id: visit.id, symbol: "state_name").first_or_initialize
# visit_parameter.content_path = "#CmbState"
# visit_parameter.data_path = "option"
# visit_parameter.data_type = "text"
# visit_parameter.ignore_value = "All States"
# visit_parameter.save

# website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdaws.com/WeatherAWSData.aspx?&FromDate=from_date&ToDate=to_date&State=state_id&District=0&Loc=0&Time=").first_or_create

# common_parameter = CommonParameter.where(website_url_id: website_url.id, symbol: "from_date").first_or_initialize
# common_parameter.value = "today, -1, %d/%m/%Y"
# common_parameter.save

# common_parameter = CommonParameter.where(website_url_id: website_url.id, symbol: "to_date").first_or_initialize
# common_parameter.value = "today, -1, %d/%m/%Y"
# common_parameter.save

# webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
# webpage_element.heading_path = ""
# webpage_element.content_path = "#DeviceData"
# webpage_element.content_loop_path = "tr:not(:nth-child(1))"
# webpage_element.data_path = "td"
# webpage_element.header_path = "tr:nth-child(1)"
# # webpage_element.folder_path = "/year/month/imd_aws"
# webpage_element.file_name = "state_name"
# webpage_element.sheet_name = "today, -1, %d/%m/%Y"
# webpage_element.save

# # Imdaws data end