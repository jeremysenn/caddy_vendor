class BalanceLog < ActiveRecord::Base
  self.primary_key = 'RowID'
  self.table_name= 'BalanceLog'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "CompanyNumber"
  belongs_to :balance_log_event_desc, :foreign_key => "EventID"
  
  after_commit :build_ach_report_web_service_call, on: [:create]
  
  scope :processed, -> { where(Processed: 1) }
  
  #############################
  #     Instance Methods      #
  #############################
  
  def description
    balance_log_event_desc.EventDescription unless balance_log_event_desc.blank?
  end
  
  def build_ach_report_web_service_call
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:build_ach_report, message: { RowID: self.RowID})
    Rails.logger.debug "build_ach_report_web_service_call response body: #{response.body}"
    if response.success?
      unless response.body[:build_ach_report_response].blank? or response.body[:build_ach_report_response][:return].to_i > 0
        return
      else
#        raise ActiveRecord::Rollback
        return nil
      end
    else
#      raise ActiveRecord::Rollback
      return nil
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  
end
