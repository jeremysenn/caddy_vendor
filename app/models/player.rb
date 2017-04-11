class Player < ApplicationRecord
  
  belongs_to :member, :foreign_key => "member_id", :class_name => 'Customer'
  belongs_to :caddy
  belongs_to :event, optional: true
#  has_one :transfer
  has_many :transfers
  has_one :caddy_rating
  
  after_create :check_caddy_out, :clear_event_color, :send_sms_notification_to_caddy
#  before_destroy :check_caddy_in
  
#  validates :tip, numericality: { :greater_than_or_equal_to => 0 }
  
  #############################
  #     Instance Methods      #
  #############################
  
  def course
    event.course
  end
  
  def carry?
    caddy_type == "Carry"
  end
  
  def chase?
    caddy_type == "Chase"
  end
  
  def total
    player_tip = tip.blank? ? 0 : tip
    player_fee = fee.blank? ? caddy_pay_rate : fee
    return (player_fee + player_tip)
  end
  
  def total_with_fee
    player_tip = tip.blank? ? 0 : tip
    player_fee = fee.blank? ? caddy_pay_rate : fee
    transaction_fee =  transfer_transaction_fee.blank? ? course.transaction_fee : transfer_transaction_fee
    return (player_fee + player_tip + transaction_fee)
  end
  
  def transfer_transaction_fee
    unless transfer.blank?
      transfer.fee
    else
      nil
    end
  end
  
  def open?
    status == 'open'
  end
  
  def closed?
    status == 'closed'
  end
  
#  def paid?
#    status == 'paid' and not payment_reversed?
#  end
  
  def paid?
    transfer.present? and not payment_reversed?
  end
  
  def payment_reversed?
    transfer.reversed? unless transfer.blank?
  end
  
  def eighteen_holes?
    round == 18
  end
  
  def nine_holes?
    round == 9
  end
  
  def round_as_string
    if eighteen_holes?
      "Eighteen Holes"
    elsif nine_holes?
      "Nine Holes"
    end
  end
  
  def caddy_pay_rate
   pay_rate = CaddyPayRate.where(ClubCompanyID: course.id, RankingID: caddy.caddy_rank_desc.id, Type: caddy_type, NbrHoles: round).first
   unless pay_rate.blank?
     pay_rate.Payrate
   else
     0
   end
  end
  
#  def member
#    Customer.find(member_id)
#  end
  
  def transfer
    transfers.last unless transfers.blank?
  end
  
  def check_caddy_out
    caddy.update_attribute(:CheckedIn, nil)
  end
  
  def check_caddy_in
    caddy.update_attribute(:CheckedIn, DateTime.now)
  end
  
  def clear_event_color
    event.update_attribute(:color, nil)
  end
  
  def send_sms_notification_to_caddy
    unless caddy.blank? or caddy.cell_phone_number.blank?
      SendCaddyNewRoundNotificationSmsWorker.perform_async(id)
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
end
