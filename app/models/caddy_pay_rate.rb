class CaddyPayRate < ApplicationRecord
  self.primary_key = 'ID'
  self.table_name= 'CaddyPayRates'
  
  establish_connection :ez_cash
  
  belongs_to :club, :foreign_key => "ClubCompanyID"
  belongs_to :caddy_rank_desc, :foreign_key => "RankingID"
    
  #############################
  #     Instance Methods      #
  #############################
  
  def acronym
    caddy_rank_desc.acronym unless caddy_rank_desc.blank?
  end
  
  #############################
  #     Class Methods         #
  #############################
end
