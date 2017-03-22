class ClearMemberBalanceWorker
  include Sidekiq::Worker

#  def perform(transfer_id)
#    transfer = Transfer.where(id: transfer_id).first
#    if transfer.ezcash_rebalance_transaction_web_service_call
#      transfer.update_attribute(:member_balance_cleared, true)
#    end
#  end

  def perform(member_account_id, club_account_id, balance)
    Member.ezcash_rebalance_transaction_web_service_call(member_account_id, company_account_id, balance)
  end
  
end
