class Company < ActiveRecord::Base
  self.primary_key = 'CompanyNumber'
  self.table_name= 'Companies'
  
  establish_connection :ez_cash
  
  has_many :users
  has_many :clubs, :foreign_key => "ClubCompanyNumber"
  has_many :members, -> { members }, :foreign_key => "CompanyNumber", :class_name => 'Customer' # Use 'members' scope in Customer
  has_many :caddies, :foreign_key => "ClubCompanyNbr"
  has_many :customers, :foreign_key => "CompanyNumber"
  
  #############################
  #     Instance Methods      #
  #############################
  
  def account
    Account.where(CompanyNumber: self.CompanyNumber, CustomerID: nil).last
  end
  
#  def members
#    customers.where(groupID: 14)
#  end
  
  #############################
  #     Class Methods      #
  #############################
  
end
