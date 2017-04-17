class ClearMemberBalanceWorker
  include Sidekiq::Worker

#  def perform(transfer_id)
#    transfer = Transfer.where(id: transfer_id).first
#    if transfer.ezcash_rebalance_transaction_web_service_call
#      transfer.update_attribute(:member_balance_cleared, true)
#    end
#  end

  def perform(transfer_id)
    transfer = Transfer.where(id: transfer_id).first
    transfer.member.credit_account(transfer.amount_paid_total)
  end
  
end
