class AccountType < ActiveRecord::Base
  self.primary_key = 'AccountTypeID'
  self.table_name= 'AccountTypes'
  
  establish_connection :ez_cash
  
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  
end
