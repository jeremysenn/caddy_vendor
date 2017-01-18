class Caddy < ApplicationRecord
#  self.primary_key = 'CustomerID'
  self.table_name= 'Caddies'
  
  establish_connection :ez_cash
  
  belongs_to :club, :foreign_key => "ClubCompanyNbr"
  belongs_to :customer, :foreign_key => "CustomerID"
  belongs_to :caddy_rank_desc, :foreign_key => "RankingID"
  has_many :players
  has_many :transfers, through: :players
  has_many :caddy_ratings
  
#  has_and_belongs_to_many :clubs

  accepts_nested_attributes_for :customer
  
  scope :active, -> { where(active: true) }

  
  #############################
  #     Instance Methods      #
  #############################
  
  def first_name
    customer.blank? ? '' : customer.NameF
  end
  
  def last_name
    customer.blank? ? '' : customer.NameL
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_name_and_club
    "#{first_name} #{last_name} - #{club.name}"
  end
  
  def cell_phone_number
    customer.blank? ? '' : customer.PhoneMobile
  end
  
#  def customer
#    Customer.where(CustomerID: self.CustomerID).first
#  end
  
  def account
    customer.account unless customer.blank?
  end
  
  def acronym
    caddy_rank_desc.acronym unless caddy_rank_desc.blank?
  end
  
  def rank_description
    caddy_rank_desc.description unless caddy_rank_desc.blank?
  end
  
  def checkin_time_today
    if checkin_today?
      self.CheckedIn
    end
  end
  
  def checkin_today?
    unless self.CheckedIn.blank?
      self.CheckedIn.today? 
    else
      false
    end
  end
  
  def inactive?
    not active?
  end
  
  def average_rating
    unless caddy_ratings.blank?
      caddy_ratings.sum(:score) / caddy_ratings.size.round(2)
    else
      0
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end
