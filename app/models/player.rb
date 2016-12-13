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
    round == "Eighteen Holes"
  end
  
  def nine_holes?
    round == "Nine Holes"
  end
  
  #############################
  #     Class Methods         #
  #############################
end
