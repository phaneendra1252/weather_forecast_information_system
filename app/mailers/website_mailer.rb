class WebsiteMailer < ActionMailer::Base
  default from: ENV['USER_EMAIL']

  def send_notification(website)

    website.attachments.each do |attachment|
      attachments[attachment.split("/").last] = File.read(attachment)
    end

    @website = website
    @reports = website.reports
    mail(:to => website.report_mail_ids, :subject => "Sucessfully parsed data")
  end

  def send_errors(website)
    # @error_report = website.exception_errors
    mail(:to => website.report_mail_ids, :subject => "Error while parsing data")
  end
end