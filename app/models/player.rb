class Player < ApplicationRecord
  belongs_to :member
  belongs_to :caddy
  belongs_to :event, optional: true
  
  #############################
  #     Instance Methods      #
  #############################
  
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
    round == '18'
  end
  
  def nine_holes?
    round == '9'
  end
  
  def pay_rate
   caddy_pay_rate = CaddyPayRate.where(ClubCompanyID: event.club.company.id, RankingAcronym: caddy.RankingAcronym, Type: caddy_type, NbrHoles: round.to_i).first
   unless caddy_pay_rate.blank?
     caddy_pay_rate.Payrate
   else
     0
   end
  end
  
  #############################
  #     Class Methods         #
  #############################
end
