class CaddyRankDesc < ApplicationRecord
  self.primary_key = 'ID'
  self.table_name= 'CaddyRankDesc'
  
  establish_connection :ez_cash
  
  belongs_to :club, :foreign_key => "ClubCompanyID"
  
  
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods         #
  #############################
end
