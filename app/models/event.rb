class Event < ApplicationRecord
  belongs_to :club
  
  has_many :players, :dependent => :destroy
  accepts_nested_attributes_for :players, allow_destroy: true, limit: 3
  
  validates :title, presence: true
  attr_accessor :date_range
  
  
  #############################
  #     Instance Methods      #
  #############################
  
  def all_day_event?
    self.start == self.start.midnight && self.end == self.end.midnight ? true : false
  end
  
  def party_size
    players.count
  end
  
  def eighteen_holes?
    round == "Eighteen Holes"
  end
  
  def nine_holes?
    round == "Nine Holes"
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
  
  def players_total
    total = 0
    players.each do |player|
      total = total + player.total
    end
    return total
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end
