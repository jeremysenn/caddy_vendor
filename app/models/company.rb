class Company < ActiveRecord::Base
  self.primary_key = 'CompanyNumber'
  self.table_name= 'Companies'
  
  establish_connection :ez_cash
  
  has_many :users
  has_many :courses, :foreign_key => "ClubCompanyNumber"
  has_many :members, -> { members }, :foreign_key => "CompanyNumber", :class_name => 'Customer' # Use 'members' scope in Customer
#  has_many :caddies, :through => :courses
  has_many :caddies, :foreign_key => "ClubCompanyNbr"
  has_many :customers, :foreign_key => "CompanyNumber"
#  has_many :transactions, :through => :customers
  has_many :caddy_pay_rates, :through => :courses
  has_many :caddy_rank_descs, :through => :courses
  has_many :events, through: :courses
#  has_many :accounts, through: :customers
#  has_many :accounts, through: :courses
  has_many :accounts
  has_many :caddy_ratings, through: :users
  has_many :transfers
  has_many :transactions, :foreign_key => "DevCompanyNbr"
  has_many :vendor_payables, :foreign_key => "CompanyNbr"
  has_many :sms_messages
  
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

  def perform_one_sided_credit_transaction(amount)
    unless account.blank?
      transaction_id = account.ezcash_one_sided_credit_transaction_web_service_call(amount) 
      Rails.logger.debug "*************** Company One-sided EZcash transaction #{transaction_id}"
      return transaction_id
    end
  end
  
  def balance
    account.Balance unless account.blank?
  end
  
  def last_cut_transaction
    account.cut_transactions.last unless account.blank?
  end
  
  def date_of_last_cut_transaction
    last_cut_transaction.date_time unless last_cut_transaction.blank?
  end
  
  def members_with_balance
    members.joins(:account).where("accounts.Balance != ?", 0)
  end
  
  def caddies_with_balance
#    caddies.joins(:customer => :account).where("accounts.Balance != ?", 0)
    caddies.select { |c| (c.holds_balance?) }
  end
  
  def caddies_total_balance
    total = 0
    caddies_with_balance.each do |caddy|
      total = total + caddy.balance
    end
    return total
  end
  
  def caddy_types
    self.caddy_pay_rates.all.distinct('Type').pluck('Type')
  end
  
  def caddy_customers
    Customer.where(CompanyNumber: self.CompanyNumber, GroupID: 13)
  end
  
  def vendor_payables_with_balance
    vendor_payables.where("Balance > ?", 0)
  end
  
  #############################
  #     Class Methods      #
  #############################
  
end
