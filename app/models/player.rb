class Player < ApplicationRecord
  
  belongs_to :member, :foreign_key => "member_id", :class_name => 'Customer'
  belongs_to :caddy
  belongs_to :event, optional: true
#  has_one :transfer
  has_many :transfers
  
#  validates :tip, numericality: { :greater_than_or_equal_to => 0 }
  
  #############################
  #     Instance Methods      #
  #############################
  
  def club
    event.club
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
   pay_rate = CaddyPayRate.where(ClubCompanyID: club.id, RankingID: caddy.caddy_rank_desc.id, Type: caddy_type, NbrHoles: round).first
   unless pay_rate.blank?
     pay_rate.Payrate
   else
     0
   end
  end
  
  def member
    Customer.find(member_id)
  end
  
  def transfer
    transfers.last unless transfers.blank?
  end
  
  #############################
  #     Class Methods         #
  #############################
end
