class CaddyPayRate < ApplicationRecord
  self.primary_key = 'ID'
  self.table_name= 'CaddyPayRates'
  
  establish_connection :ez_cash
  
  belongs_to :club, :foreign_key => "ClubCompanyID"
    
  #############################
  #     Instance Methods      #
  #############################
  
  def caddy_rank_desc
    CaddyRankDesc.where(ClubCompanyID: self.ClubCompanyID, RankingAcronym: self.RankingAcronym).last
  end
  
  #############################
  #     Class Methods         #
  #############################
end
