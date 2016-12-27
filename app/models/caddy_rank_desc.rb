class CaddyRankDesc < ApplicationRecord
  self.primary_key = 'ID'
  self.table_name= 'CaddyRankDesc'
  
  establish_connection :ez_cash
  
  belongs_to :club, :foreign_key => "ClubCompanyID"
  has_many :caddies, :foreign_key => "RankingID"
  has_many :caddy_pay_rates, :foreign_key => "RankingID"
  
  
  #############################
  #     Instance Methods      #
  #############################
  
  def acronym
    self.RankingAcronym
  end
  
  #############################
  #     Class Methods         #
  #############################
end
