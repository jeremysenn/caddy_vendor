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
      ['Checked In',  caddies.select{|caddy| caddy.checkin_today?}.sort_by {|c| c.last_name}.collect { |c| [ c.full_name, c.id ] }],
      ['Checked Out',  caddies.select{|caddy| not caddy.checkin_today?}.sort_by {|c| c.last_name}.collect { |c| [ c.full_name, c.id ] }]
    ]
  end
  
  #############################
  #     Class Methods         #
  #############################
end
