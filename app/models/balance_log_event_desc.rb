class BalanceLogEventDesc < ActiveRecord::Base
#  self.primary_key = 'RowID'
  self.table_name= 'BalanceLogEventDesc'
  
  establish_connection :ez_cash
  
  has_many :balance_logs, :foreign_key => "EventID"
  
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  
end
