class CaddyPayRate < ApplicationRecord
  self.primary_key = 'ClubCompanyID'
  self.table_name= 'CaddyPayRates'
  
  establish_connection :ez_cash
  
  belongs_to :club, :foreign_key => "ClubCompanyID"
    
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods         #
  #############################
end
