class WebsiteMailer < ActionMailer::Base
  default from: ENV['USER_EMAIL']

  def send_notification(website, websites)

    website.attachments.each do |attachment|
      attachments[attachment.split("/").last] = File.read(attachment)
    end

    @website = website
    @reports = website.reports(websites)
    parsed_websites = @website.parsed_websites.join(", ")
    mail(:to => website.report_mail_ids, :subject => "#{Date.today-1} Sucessfully parsed data for #{parsed_websites}")
  end

  def send_errors(website)
    # @error_report = website.exception_errors
    parsed_websites = website.parsed_websites.join(", ")
    mail(:to => website.report_mail_ids, :subject => "#{Date.today-1} Error while parsing #{parsed_websites}")
  end
end