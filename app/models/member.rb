class Member < ApplicationRecord
  has_and_belongs_to_many :clubs
  
  #############################
  #     Instance Methods      #
  #############################
 
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.ezcash_rebalance_transaction_web_service_call(member_account_id, club_account_id, balance)
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:ez_cash_txn, message: { FromActID: club_account_id, ToActID: member_account_id, Amount: balance.to_f.abs})
    
    Rails.logger.debug "Response body: #{response.body}"
    if response and response.success?
      unless response.body[:ez_cash_txn_response].blank? or response.body[:ez_cash_txn_response][:return].to_i > 0
        return true
      else
        return nil
      end
    else
      return nil
    end
  end
  
end
