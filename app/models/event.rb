class Event < ApplicationRecord
  belongs_to :club
  
  has_many :players, :dependent => :destroy
  accepts_nested_attributes_for :players, allow_destroy: true, limit: 5
  
#  validates :title, presence: true
  attr_accessor :date_range
  
  #############################
  #     Instance Methods      #
  #############################
  
  def player_names
    names = ''
    players.each do |player|
      names = names + ' ' + player.member.full_name
    end
    return names
  end
  
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
    players.where(status: [nil, 'open', 'closed']).count > 0
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
  
  #############################
  #     Class Methods         #
  #############################
  
end
