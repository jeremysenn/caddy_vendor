class CaddyRankDesc < ApplicationRecord
#  self.primary_key = 'Transaction_ID'
  self.table_name= 'CaddyRankDesc'
  
  establish_connection :ez_cash
  
  
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods         #
  #############################
end
