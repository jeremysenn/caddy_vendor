class Transaction < ActiveRecord::Base
  self.primary_key = 'tranID'
  self.table_name= 'transactions'
  
  establish_connection :ez_cash
  belongs_to :device, :foreign_key => :dev_id
  
  #############################
  #     Instance Methods      #
  #############################
  
  def type
    unless tran_code.blank? or sec_tran_code.blank?
      if (tran_code.strip == "CHK" and sec_tran_code.strip == "TFR")
        return "Check Cashed"
      elsif (tran_code.strip == "CHKP" and sec_tran_code.strip == "TFR")
        return "Positive Check Cashed"
      elsif (tran_code.strip == "CASH" and sec_tran_code.strip == "TFR")
        return "Cash Deposit"
      elsif (tran_code.strip == "MON" and sec_tran_code.strip == "ORD")
        return "Money Order"
      elsif (tran_code.strip == "WDL" and sec_tran_code.strip == "REVT")
        return "Reverse Withdrawal"
      elsif (tran_code.strip == "WDL" and sec_tran_code.strip == "TFR")
        return "Withdrawal"
      elsif (tran_code.strip == "CARD" and sec_tran_code.strip == "TFR")
        return "Card Transfer"
      elsif (tran_code.strip == "BILL" and sec_tran_code.strip == "PAY")
        return "Bill Pay"
      elsif (tran_code.strip == "POS" and sec_tran_code.strip == "TFR")
        return "Purchase"
      elsif (tran_code.strip == "PUT" and sec_tran_code.strip == "TFR")
        return "Wire Transfer"
      elsif (tran_code.strip == "FUND" and sec_tran_code.strip == "TFR")
        return "Fund Transfer"
      elsif (tran_code.strip == "CRED" and sec_tran_code.strip == "TFR")
        return "Account Credit"
      else
        return "Unknown"
      end
    end
  end
  
#  def debit?(account_number)
#    bill_pay? or money_order? or withdrawal? or transfer_out?(account_number) or purchase?
#  end

  def debit?
    wire_transfer_out? or bill_pay? or money_order? or withdrawal? or transfer_out? or purchase?
  end
  
  def debit?(account_id)
    fund_transfer_out?(account_id) or wire_transfer_out?(account_id) or bill_pay? or money_order? or withdrawal? or transfer_out?(account_id) or purchase?
  end
  
#  def debit?(account_number)
#    from_acct_nbr == account_number
#  end
  
  def credit?(account_number)
    fund_transfer_in? or wire_transfer_in? or check_cashed? or positive_check_cashed? or cash_deposit? or reverse_withdrawal? or transfer_in? (account_number)
  end
  
  def bill_pay?
    type == "Bill Pay"
  end
  
  def money_order?
    type == "Money Order"
  end
  
  def withdrawal?
    type == "Withdrawal"
  end
  
  def reverse_withdrawal?
    type == "Reverse Withdrawal"
  end
  
  def card_transfer?
    type == "Card Transfer"
  end
  
  def check_cashed?
    type == "Check Cashed"
  end
  
  def positive_check_cashed?
    type == "Positive Check Cashed"
  end
  
  def cash_deposit?
    type == "Cash Deposit"
  end
  
  def purchase?
    type == "Purchase"
  end
  
  def wire_transfer?
    type == "Wire Transfer"
  end
  
  def fund_transfer?
    type == "Fund Transfer"
  end
  
#  def transfer_in?(account_number)
#    card_transfer? and to_acct_nbr == account_number
#  end
  
  def transfer_in?
    card_transfer? and to_acct_id == self.ActID
  end
  
  def wire_transfer_in?
    wire_transfer? and to_acct_id == self.ActID
  end
  
#  def transfer_out?(account_number)
#    card_transfer? and from_acct_nbr == account_number
#  end
  
  def transfer_out?
    card_transfer? and from_acct_id == self.ActID
  end
  
  def transfer_out?(account_id)
    card_transfer? and from_acct_id == account_id
  end
  
  def wire_transfer_out?
    wire_transfer? and from_acct_id == self.ActID
  end
  
  def wire_transfer_out?(account_id)
    wire_transfer? and from_acct_id == account_id
  end
  
  def fund_transfer_out?(account_id)
    fund_transfer? and from_acct_id == account_id
  end
  
  def reversal?
    type == "Account Credit"
  end
  
  def account
#    Account.where(ActID: self.ActID).last
    Account.where(ActID: card_nbr).last
  end
  
  def images
    images = Image.where(ticket_nbr: id.to_s)
    unless images.blank?
      return images
    else
      return []
    end
  end
  
  def front_side_check_images
    images = Image.where(ticket_nbr: id.to_s, event_code: "FS")
    unless images.blank?
      return images
    else
      return []
    end
  end
  
  def back_side_check_images
    images = Image.where(ticket_nbr: id.to_s, event_code: "BS")
    unless images.blank?
      return images
    else
      return []
    end
  end
  
  def customer
    Customer.find(self.custID)
  end
  
  def amount_with_fee
    unless self.ChpFee.blank? or self.ChpFee.zero?
      if self.FeedActID == self.from_acct_id
        return amt_auth + self.ChpFee
      elsif self.FeedActID == self.to_acct_id
        return amt_auth - self.ChpFee
      else
        return amt_auth - self.ChpFee
      end
    else
      return amt_auth
    end
  end
  
  def amount_with_fee(account_id)
    unless self.ChpFee.blank? or self.ChpFee.zero?
      if self.FeedActID == account_id
        if self.from_acct_id == account_id
          return amt_auth + self.ChpFee
        else
          return amt_auth - self.ChpFee
        end
      else
        return amt_auth
      end
    else
      return amt_auth
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
end
