class Player < ApplicationRecord
  
  belongs_to :member, :foreign_key => "member_id", :class_name => 'Customer'
#  belongs_to :caddy
  belongs_to :event, optional: true
  has_one :transfer
  
  validates :tip, numericality: { :greater_than_or_equal_to => 0 }
  
  #############################
  #     Instance Methods      #
  #############################
  
  def caddy
    Caddy.where(CustomerID: caddy_id, ClubCompanyNbr: club.id).first
  end
  
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
    fee + tip
  end
  
  def open?
    status == 'open'
  end
  
  def closed?
    status == 'closed'
  end
  
  def paid?
    status == 'paid'
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
   pay_rate = CaddyPayRate.where(ClubCompanyID: club.id, RankingAcronym: caddy.RankingAcronym, Type: caddy_type, NbrHoles: round).first
   unless pay_rate.blank?
     pay_rate.Payrate
   else
     0
   end
  end
  
  def member
    Customer.find(member_id)
  end
  
  #############################
  #     Class Methods         #
  #############################
end
