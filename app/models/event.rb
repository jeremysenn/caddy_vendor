class Event < ApplicationRecord
  belongs_to :course
  
  has_many :players, :dependent => :destroy
  accepts_nested_attributes_for :players, allow_destroy: true, limit: 5
  has_many :transfers, through: :players
  
#  validates :title, presence: true
  attr_accessor :date_range
  
  #############################
  #     Instance Methods      #
  #############################
  
  def player_names
    names = ''
    players.each do |player|
      unless player.member.blank?
        names = names + ' ' + player.member.full_name
      end
    end
    return names
  end
  
  def player_names_with_caddy_names
    names = ''
    players.each do |player|
      unless player.member.blank? or player.caddy.blank?
        if player.note.blank?
          names = names + ' ' + player.member.full_name + ' (' + player.caddy.full_name + ')'
        else
          names = names + ' ' + player.note + ' (' + player.caddy.full_name + ')'
        end
      end
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
  
  def players_total_with_fee
    total = 0
    players.each do |player|
      total = total + player.total_with_fee
    end
    return total
  end
  
  def not_paid?
    players.where(status: [nil, 'open', 'closed']).count > 0
  end
  
  def contains_paid_players?
    players.where(status: ['paid']).count > 0
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
