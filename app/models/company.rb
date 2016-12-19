class Company < ActiveRecord::Base
  self.primary_key = 'CompanyNumber'
  self.table_name= 'Companies'
  
  establish_connection :ez_cash
  
  has_many :users
  has_many :clubs, :foreign_key => "ClubCompanyNumber"
  has_many :members, -> { members }, :foreign_key => "CompanyNumber", :class_name => 'Customer' # Use 'members' scope in Customer
  has_many :caddies, :through => :clubs
  has_many :customers, :foreign_key => "CompanyNumber"
  
  has_many :caddy_rank_descs, :foreign_key => "ClubCompanyID"
  
  #############################
  #     Instance Methods      #
  #############################
  
  def account
    Account.where(CompanyNumber: self.CompanyNumber, CustomerID: nil).last
  end
  
  def caddy_rankings_array
    rankings = []
    caddy_rank_descs.each do |caddy_rank|
      rankings << caddy_rank.RankingAcronym
    end
    return rankings
  end
  
#  def members
#    customers.where(groupID: 14)
#  end
  
  #############################
  #     Class Methods      #
  #############################
  
end
