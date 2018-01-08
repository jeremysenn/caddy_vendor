class CaddyRankDesc < ApplicationRecord
  self.primary_key = 'ID'
  self.table_name= 'CaddyRankDesc'
  
  establish_connection :ez_cash
  
  belongs_to :course
  belongs_to :company, :foreign_key => "ClubCompanyID"
  has_many :caddies, :foreign_key => "RankingID"
  has_many :caddy_pay_rates, :foreign_key => "RankingID"
  
  
  #############################
  #     Instance Methods      #
  #############################
  
  def acronym
    self.RankingAcronym
  end
  
  def description
    self.RankingDescription
  end
  
#  def grouped_for_select
#    [self.RankingAcronym, caddies.active.sort_by {|c| c.last_name}.collect { |c| [ c.full_name_with_check_in_status, c.id ] }]
#  end
  
  def grouped_for_select
    [self.RankingAcronym, caddies.active.sort_by {|c| c.first_name}.collect { |c| [ c.full_name_with_check_in_status, c.id ] }]
  end
  
  #############################
  #     Class Methods         #
  #############################
end
