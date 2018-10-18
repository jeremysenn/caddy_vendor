class ApplicationMailer < ActionMailer::Base
  default from: 'info@caddyvend.com'
  layout 'mailer'
  
  def send_member_email_notification(company, to, body)
    @body = body
#    mail(:to => to, :reply_to => 'jeremy@tranact.com', :subject => "CaddyVend Transfer Notification")
    mail(:to => to, :reply_to => "#{company.reply_to_emails.blank? ? nil : company.reply_to_emails.delete(' ').strip}", :subject => "CaddyVend Transfer Notification")
  end
end
