class BalanceLog < ActiveRecord::Base
  self.primary_key = 'RowID'
  self.table_name= 'BalanceLog'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "CompanyNumber"
  belongs_to :balance_log_event_desc, :foreign_key => "EventID"
  
  #############################
  #     Instance Methods      #
  #############################
  
  def description
    balance_log_event_desc.EventDescription unless balance_log_event_desc.blank?
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.build_ach_report_web_service_call(balance_log_id)
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:build_ach_report, message: { RowID: balance_log_id})
    Rails.logger.debug "Response body: #{response.body}"
  end
  
  
end
