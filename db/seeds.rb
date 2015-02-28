# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin_role = Role.where(name: "admin").first_or_create
moderator_role = Role.where(name: "moderator").first_or_create

if User.where(email: "ganni.phaneendra@gmail.com").blank?
	user = User.new(name: "Surya", email: "ganni.phaneendra@gmail.com", password: "testing123", password_confirmation: "testing123")
	user.role_ids = [admin_role.id, moderator_role.id]
	user.save
end

setting = Setting.where(key: "file_path").first_or_initialize
setting.value = "/home/surya/project_files/wfis"
setting.save

# imd_gov_in start

website = Website.where(name: "imd_gov_in").first_or_initialize
website.folder_path = "/year/month/imd_gov_in"
website.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdhyderabad.gov.in/apsite/apobs.html").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "table tr:nth-child(1)"
webpage_element.content_path = "table tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "table tr:nth-child(2)"
# webpage_element.folder_path = "/year/month/imd_gov_in"
webpage_element.file_name = "andhra_pradesh"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdhyderabad.gov.in/tssite/tlngobs.htm").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "table tr:nth-child(1)"
webpage_element.content_path = "table tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "table tr:nth-child(2)"
# webpage_element.folder_path = "/year/month/imd_gov_in"
webpage_element.file_name = "telangana"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

website_url = WebsiteUrl.where(website_id: website.id, url: "http://www.imdchennai.gov.in/obs_data.htm").first_or_create

webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
webpage_element.heading_path = "#table1 tr:nth-child(1)"
webpage_element.content_path = "#table1 tr:not(:nth-child(1)):not(:nth-child(2))"
webpage_element.data_path = "td"
webpage_element.header_path = "#table1 tr:nth-child(2)"
# webpage_element.folder_path = "/year/month/imd_gov_in"
webpage_element.file_name = "tamilnadu"
webpage_element.sheet_name = "today, -1, %d/%m/%Y"
webpage_element.save

# imd_gov_in end

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
# webpage_element.content_path = "#DeviceData tr:not(:nth-child(1))"
# webpage_element.data_path = "td"
# webpage_element.header_path = "#DeviceData tr:nth-child(1)"
## webpage_element.folder_path = "/year/month/imd_aws"
# webpage_element.file_name = "state_name"
# webpage_element.sheet_name = "today, -1, %d/%m/%Y"
# webpage_element.save

# # Imdaws data end

# # Tamilnadu data start
# website = Website.where(name: "tamilnadu_data").first_or_initialize
# website.folder_path = "/year/month/tamilnadu_data"
# website.save
# visit = Visit.where(website_id: website.id, url: "http://tawn.tnau.ac.in").first_or_create

# visit = Visit.where(website_id: website.id, url: "http://tawn.tnau.ac.in/General/DistrictWiseSummaryPublicUI.aspx?RW=1").first_or_create

# visit_parameter = VisitParameter.where(visit_id: visit.id, symbol: "district_id").first_or_initialize
# visit_parameter.content_path = "select#ddlDistrict"
# visit_parameter.data_path = "option"
# visit_parameter.data_type = "value"
# visit_parameter.ignore_value = "0"
# visit_parameter.visit_parameter_url = "http://tawn.tnau.ac.in/General/BlockWiseSummaryPublicUI.aspx?EntityHierarchyOneKey=district_id&lang=en"
# visit_parameter.save

# visit_parameter = VisitParameter.where(visit_id: visit.id, symbol: "district_name").first_or_initialize
# visit_parameter.content_path = "select#ddlDistrict"
# visit_parameter.data_path = "option"
# visit_parameter.data_type = "text"
# visit_parameter.ignore_value = "-- All --"
# visit_parameter.visit_parameter_url = ""
# visit_parameter.save

# respective_visit = RespectiveVisit.where(visit_id: visit.id, symbol: "block_id").first_or_initialize
# respective_visit.content_path = "select#ddlBlock"
# respective_visit.data_path = "option"
# respective_visit.data_type = "value"
# respective_visit.ignore_value = "0"
# respective_visit.save

# respective_visit = RespectiveVisit.where(visit_id: visit.id, symbol: "block_name").first_or_initialize
# respective_visit.content_path = "select#ddlBlock"
# respective_visit.data_path = "option"
# respective_visit.data_type = "text"
# respective_visit.ignore_value = "-- All --"
# respective_visit.save

# website_url = WebsiteUrl.where(website_id: website.id, url: "http://tawn.tnau.ac.in/General/BlockLastDayWeatherDataPublicUI.aspx?EntityHierarchyOneKey=district_id&EntityHierarchyTwoKey=block_id&lang=en").first_or_create

# webpage_element = WebpageElement.where(website_url_id: website_url.id).first_or_initialize
# webpage_element.heading_path = ""
# webpage_element.content_path = "#DynamicWeatherDataDiv > div"
# webpage_element.data_path = "div"
# webpage_element.header_path = "#DynaicHeaderDiv > div"
## webpage_element.folder_path = "/year/month/tamilnadu_data"
# webpage_element.file_name = "block_name"
# webpage_element.sheet_name = "today, -1, %d/%m/%Y"
# webpage_element.save

# # Tamilnadu data end