namespace :parse_data do
  desc "Parse data of websites"
  task :parse_wfis_data => :environment do
    Website.parse_wfis
  end
end