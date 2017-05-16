class VendorPayable < ApplicationRecord
  
  establish_connection :ez_cash
  self.table_name= 'VendorPayables'
  
#  belongs_to :customer, :foreign_key => "CustID"
  belongs_to :company, :foreign_key => "CompanyNbr"
  
  
end
