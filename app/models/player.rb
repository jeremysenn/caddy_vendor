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
  
  #############################
  #     Class Methods         #
  #############################
end
