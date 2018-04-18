class ApplicationMailer < ActionMailer::Base
  default from: 'info@caddyvend.com'
  layout 'mailer'
  
  def send_member_email_notification(to, body)
    @body = body
    mail(:to => to, :subject => "CaddyVend Transfer Notification")
  end
end
