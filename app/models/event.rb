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
    round == "18"
  end
  
  def nine_holes?
    round == "9"
  end
  
  def players_total
    total = 0
    players.each do |player|
      total = total + player.total
    end
    return total
  end
  
  def not_paid?
    players.where.not(status: 'paid').count > 0
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end
