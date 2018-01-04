class CompanyActDefaultMinBal < ActiveRecord::Base
#  self.primary_key = 'AccountTypeID'
  self.table_name= 'CompanyActDefaultMinBal'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "CompanyNumber"
  
  #############################
  #     Instance Methods      #
  #############################
  
  
  #############################
  #     Class Methods      #
  #############################
  
  
end
