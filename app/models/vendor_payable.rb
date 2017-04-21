class VendorPayable < ApplicationRecord
  
  establish_connection :ez_cash
  self.table_name= 'VendorPayables'
  
end
