namespace :parse_data do
  desc "Parse data of websites"
  task :parse_wfis_data => :environment do
    Website.parse_wfis_website_by_website
  end

  task :test => :environment do
    Website.test
  end

end