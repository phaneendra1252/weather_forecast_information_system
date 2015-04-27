class WebsiteMailer < ActionMailer::Base
  default from: ENV['USER_EMAIL']

  def send_notification(website)
    @website = website
    @reports = website.reports
    mail(:to => website.report_mail_ids, :subject => "Sucessfully parsed data")
  end

end