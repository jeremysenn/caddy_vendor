class CaddyPayRate < ApplicationRecord
  self.primary_key = 'ID'
  self.table_name= 'CaddyPayRates'
  
  establish_connection :ez_cash
  
  belongs_to :course, :foreign_key => "ClubCompanyID"
  belongs_to :caddy_rank_desc, :foreign_key => "RankingID"
  
  validates_numericality_of :Payrate, :greater_than => 0
    
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
