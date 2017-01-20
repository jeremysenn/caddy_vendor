class Club < ApplicationRecord
  self.primary_key = 'ClubCourseID'
  self.table_name= 'CaddyCourses'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "ClubCompanyNumber"
  has_many :events
  has_many :caddies, :foreign_key => "ClubCompanyNbr"
  has_many :caddy_pay_rates, :foreign_key => "ClubCompanyID"
  has_many :caddy_rank_descs, :foreign_key => "ClubCompanyID"
  has_many :transfers, through: :events
  
  attr_accessor :transaction_fee

  #############################
  #     Instance Methods      #
  #############################
  
  def name
    self.CourseName
  end
  
  def caddy_rankings_array
    rankings = []
    caddy_rank_descs.each do |caddy_rank|
      rankings << caddy_rank.RankingAcronym
    end
    return rankings.uniq
  end
  
  def grouped_caddies_for_select
    [
      ['Checked In',  caddies.active.select{|caddy| caddy.checkin_today?}.sort_by {|c| c.last_name}.collect { |c| [ c.full_name, c.id ] }],
      ['Checked Out',  caddies.active.select{|caddy| not caddy.checkin_today?}.sort_by {|c| c.last_name}.collect { |c| [ c.full_name, c.id ] }]
    ]
  end
  
  ### Start Virtual Attributes ###
  def transaction_fee # Getter
    transaction_fee_cents.to_d / 100 if transaction_fee_cents
  end
  
  def transaction_fee=(dollars) # Setter
    self.transaction_fee_cents = dollars.to_d * 100 if dollars.present?
  end
  ### End Virtual Attributes ###
  
  def account
    Account.where(CompanyNumber: id, CustomerID: nil).first
  end
  
  #############################
  #     Class Methods         #
  #############################
end
