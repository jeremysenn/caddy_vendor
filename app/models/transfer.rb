class Transfer < ApplicationRecord
  belongs_to :customer
  belongs_to :player, optional: true
  belongs_to :ez_cash_transaction, class_name: "Transaction", :foreign_key => "ezcash_tran_id"
  belongs_to :company
  
#  after_create :transfer_web_service_call
  after_save :update_player, if: :contains_player?
  
  after_create :ezcash_payment_transaction_web_service_call, unless: :reversed?
  after_create :send_member_sms_notification, unless: :reversed?
#  after_create :ezcash_send_sms_web_service_call, if: :contains_player?
  after_update :ezcash_reverse_transaction_web_service_call
  
#  validates :from_account, :to_account, :amount, :fee, presence: true
#  validate :amount_not_greater_than_available

#  validates_numericality_of :caddy_fee_cents, :greater_than => 0

  validates :caddy_fee_cents, numericality: { greater_than_or_equal_to: 0}
  validates :caddy_tip_cents, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 9900,  message: "Tip must be under $100" }

  # Virtual Attributes
  attr_accessor :generate_reversal

  #############################
  #     Instance Methods      #
  ############################
  
  
  ### Start Virtual Attributes ###
  def amount # Getter
    unless reversed
      amount_cents.to_d / 100 if amount_cents
    else
      # Return negative value if transfer has been reversed
      -(amount_cents.to_d / 100) if amount_cents
    end
  end
  
  def amount=(dollars) # Setter
    self.amount_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def caddy_fee # Getter
    unless reversed
      caddy_fee_cents.to_d / 100 if caddy_fee_cents
    else
      # Return negative value if transfer has been reversed
      -(caddy_fee_cents.to_d / 100) if caddy_fee_cents
    end
  end
  
  def caddy_fee=(dollars) # Setter
    self.caddy_fee_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def caddy_tip # Getter
    unless reversed
      caddy_tip_cents.to_d / 100 if caddy_tip_cents
    else
      # Return negative value if transfer has been reversed
      -(caddy_tip_cents.to_d / 100) if caddy_tip_cents
    end
  end
  
  def caddy_tip=(dollars) # Setter
    self.caddy_tip_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def fee # Getter
    fee_cents.to_d / 100 if fee_cents
  end
  
  def fee=(dollars) # Setter
    self.fee_cents = dollars.to_d * 100 if dollars.present?
  end
  
  def from_account # Getter
    from_account_id if from_account_id
  end
  
  def from_account=(id) # Setter
    self.from_account_id = id if id.present?
  end
  
  def to_account # Getter
    to_account_id if to_account_id
  end
  
  def to_account=(id) # Setter
    self.to_account_id = id if id.present?
  end
  ### End Virtual Attributes ###
  
  def from_account_record
    Account.where(ActID: from_account_id).first
  end
  
  def to_account_record
    Account.where(ActID: to_account_id).first
  end
  
  def amount_not_greater_than_available
    errors.add(:amount, "cannot be greater than available balance of #{from_account_record.available_balance}") if self.amount > from_account_record.available_balance
  end
  
  def ezcash_payment_transaction_web_service_call
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    response = client.call(:ez_cash_txn, message: { FromActID: from_account_id, ToActID: to_account_id, Amount: amount, Fee: fee, FeeActId: fee_to_account_id})
    Rails.logger.debug "************** ezcash_payment_transaction_web_service_call response body: #{response.body}"
    if response.success?
      unless response.body[:ez_cash_txn_response].blank? or response.body[:ez_cash_txn_response][:return].to_i > 0
        self.update_attribute(:ez_cash_tran_id, response.body[:ez_cash_txn_response][:tran_id])
#        self.ez_cash_tran_id = response.body[:ez_cash_txn_response][:tran_id]
#        self.save
      else
        raise ActiveRecord::Rollback
        return nil
      end
    else
      raise ActiveRecord::Rollback
      return nil
    end
  end
  
  def ezcash_rebalance_transaction_web_service_call
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    if player.member.balance == amount_paid_total
      # The totals match
      response = client.call(:ez_cash_txn, message: { FromActID: player.course.account.id, ToActID: from_account_id, Amount: amount_paid_total})
    else
      # The totals don't match, so zero out the member's balance
      response = client.call(:ez_cash_txn, message: { FromActID: player.course.account.id, ToActID: from_account_id, Amount: player.member.balance.abs})
    end
    Rails.logger.debug "Response body: #{response.body}"
    if response.success?
      unless response.body[:ez_cash_txn_response].blank? or response.body[:ez_cash_txn_response][:return].to_i > 0
        return true
      else
        raise ActiveRecord::Rollback
        return nil
      end
    else
      raise ActiveRecord::Rollback
      return nil
    end
  end
  
  def ezcash_reverse_transaction_web_service_call
    if self.generate_reversal == "true"
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      response = client.call(:ez_cash_txn, message: { TranID: ez_cash_tran_id })
      Rails.logger.debug "****************Response body for reversing transfer: #{response.body}"
      if response.success?
        unless response.body[:ez_cash_txn_response].blank? or response.body[:ez_cash_txn_response][:return].to_i > 0
#          unless club_credit_transaction_id.blank?
#            # Also need to reverse the original one-side course credit transaction if there was one with this transfer
#            company.perform_one_sided_credit_transaction(-amount_paid_total) # Use negative of transfer's total amount paid
#          end

          # Create a new transfer to represent the reversal
          Transfer.create(from_account_id: from_account_id, to_account_id: to_account_id, customer_id: customer_id, player_id: player_id, 
            caddy_fee_cents: caddy_fee_cents, caddy_tip_cents: caddy_tip_cents, amount_cents: amount_cents, fee_cents: fee_cents, ez_cash_tran_id: response.body[:ez_cash_txn_response][:tran_id], 
            reversed: true, fee_to_account_id: fee_to_account_id, member_balance_cleared: member_balance_cleared, company_id: company_id, note: note,
            club_credit_transaction_id: club_credit_transaction_id)

          return true
        else
          raise ActiveRecord::Rollback
          return nil
        end
      else
        raise ActiveRecord::Rollback
        return nil
      end
    end
  end
  
  def ezcash_send_sms_web_service_call
    unless member.blank? or member.phone.blank? or ez_cash_tran_id.blank?
      unless caddy.blank?
#        client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
#        response = client.call(:send_sms, message: { Phone: member.phone, Msg: "Hi #{member.first_name}, please rate your caddy by going here: #{Rails.application.routes.url_helpers.new_caddy_rating_url(player_id: player.id)}"})
#        Rails.logger.debug "Response body: #{response.body}"
        SendCaddyRatingSmsWorker.perform_async(id)
      end
    end
  end
  
  def amount_in_dollars
    unless reversed
      amount_cents / 100.0
    else
      # Return negative value if transfer has been reversed
      -(amount_cents / 100.0)
    end
  end
  
  def fee_in_dollars
    unless reversed
      fee_cents / 100.0 unless fee_cents.blank?
    else
      # Return negative value if transfer has been reversed
      -(fee_cents / 100.0) unless fee_cents.blank?
    end
  end
  
  def total
#    (amount_cents - fee_cents) / 100
#    (amount_cents + fee_cents) / 100.0 unless amount_cents.blank? or fee_cents.blank?
    unless reversed
      (amount_cents) / 100.0 unless amount_cents.blank?
    else
      # Return negative value if transfer has been reversed
      -((amount_cents) / 100.0) unless amount_cents.blank?
    end
  end
  
  def update_player
    unless reversed?
      player.update_attributes(status: 'paid', fee: caddy_fee, tip: caddy_tip)
      unless player.event.not_paid? 
        # Payment has been processed for all players
        player.event.update_attribute(:color, 'green')
      end
    else
      player.update_attribute(:status, nil)
      player.event.update_attribute(:color, nil)
    end
  end
  
  def to_account
    Account.where(ActID: to_account_id).first
  end
  
  def to_customer
    to_account.customer unless to_account.blank?
  end
  
  def reversable?
    unless player and player.payment_reversed?
      not ez_cash_tran_id.blank? and not reversed?
    else
      false
    end
  end
  
  def member
    unless player.blank?
      player.member 
    else
      unless customer.blank?
        customer
      end
    end
  end
  
  def caddy
    unless player.blank?
      player.caddy 
    else
      Caddy.where(CustomerID: to_account_record.customer.id).first unless to_account_record.blank? or to_account_record.customer.blank?
    end
  end
  
  def course
    unless player.blank?
      player.course
    else
      unless caddy.blank?
        caddy.course
      else
        company.courses.first
      end
    end
  end
  
  ### Start methods for use with generating CSV file ###
  def date_of_play # Date of play
   
    unless player.blank? or player.event.blank?
      player.event.start.to_date
    else
      # Use transfer's created_at date if there is no player/round associated with transfer
      created_at.to_date
    end
    
#    unless player.blank? or player.event.blank?
#      player.event.start.in_time_zone(course.time_zone).to_date
#    else
#      # Use transfer's created_at date if there is no player/round associated with transfer
#      created_at.in_time_zone(course.time_zone).to_date
#    end
  end
  
  def member_number # Member number
    unless player.blank?
      player.member.member_number 
    else
      customer.member_number unless customer.blank?
    end
  end
  
  def member_extension # Member extension
    unless player.blank?
      player.member.member_extension
    else
      customer.member_extension unless customer.blank?
    end
  end
  
  def member_name
    unless player.blank? or player.member.blank?
      player.member.primary_member.full_name 
    else
      unless customer.blank?
        customer.primary_member.full_name 
      end
    end
  end
  
  def amount_paid_to_caddy
    unless player.blank?
      fee = caddy_fee.blank? ? 0 : caddy_fee
      tip = caddy_tip.blank? ? 0 : caddy_tip
      return fee + tip
    else
      amount_paid_total
    end
  end
  
  def amount_paid_total # Amount paid total
#    fee = caddy_fee.blank? ? 0 : caddy_fee
#    tip = caddy_tip.blank? ? 0 : caddy_tip
    amount = total
    trans_fee = transaction_fee.blank? ? 0 : transaction_fee
#    return fee + tip + trans_fee
    return amount + trans_fee
  end
  
  def amount_billed # Amount billed. Same as Amount paid total
    amount = total
    trans_fee = transaction_fee.blank? ? 0 : transaction_fee
    return amount + trans_fee
  end
  
  def date_caddy_paid
#    created_at.in_time_zone(course.time_zone).to_date
    created_at.to_date
  end
  
  def caddy_name
    caddy.full_name unless caddy.blank?
  end
  
  def transaction_fee
    fee_in_dollars
  end
  
  def reference_number
    ez_cash_tran_id
  end
  
  def member_guest
    player.note unless player.blank?
  end
  
  def player_name
    unless player.blank?
      unless member_guest.blank? or member_guest == 'None'
        member_guest
      else
        player.member.full_name unless player.member.blank?
      end
    end
  end
  ### End methods for use with generating CSV file ###
  
  def contains_player?
    not player.blank?
  end
  
  def description
    unless from_account_record.customer.blank?
      from_name = from_account_record.customer.full_name
    else
      from_name = from_account_id
    end
    unless to_account_record.customer.blank?
      to_name = to_account_record.customer.full_name
    else
      to_name = to_account_id
    end
    
    return "#{from_name} to #{to_name}"
  end
  
  def from_customer?
    not customer_id.blank?
  end
  
  def holes
    unless player.blank?
      player.round
    end
  end
  
  def caddy_rank
    caddy.acronym unless caddy.blank?
  end
  
  def reference
    "#{holes} #{caddy_rank} Caddie Cash Advance #{note} #{player_name}"
  end
  
  def caddy_type
    unless player.blank?
      player.caddy_type
    end
  end
  
  def send_member_sms_notification
    unless member.blank? or member.phone.blank?
      unless player.blank?
        message_body = "You have been billed $#{amount_billed} by #{company.name} for #{caddy.full_name} #{player.round} #{player.caddy_type}."
        SendMemberSmsWorker.perform_async(member.phone, member.id, company_id, message_body)
      else
        message_body = "You have been billed $#{amount_billed} by #{company.name} for #{caddy.full_name}."
        SendMemberSmsWorker.perform_async(member.phone, member.id, company_id, message_body)
      end
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.to_csv
    require 'csv'
    attributes = %w{date_of_play member_number member_extension amount_billed player_name member_name date_caddy_paid amount_paid_to_caddy caddy_name caddy_rank caddy_type holes reference_number note reference}
    
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |transfer|
        csv << attributes.map{ |attr| transfer.send(attr) }
      end
    end
  end
  
end
