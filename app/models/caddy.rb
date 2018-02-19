class Caddy < ApplicationRecord
#  self.primary_key = 'CustomerID'
  self.table_name= 'Caddies'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "ClubCompanyNbr"
#  belongs_to :course
  belongs_to :customer, :foreign_key => "CustomerID"
  belongs_to :caddy_rank_desc, :foreign_key => "RankingID"
  has_many :players
  has_many :transfers, through: :players
  has_many :caddy_ratings
  has_many :sms_messages
  has_many :events, through: :players
  
#  has_and_belongs_to_many :courses

  accepts_nested_attributes_for :customer
  
  scope :active, -> { where(active: true) }

  
  #############################
  #     Instance Methods      #
  #############################
  
  def first_name
    (customer.blank? or customer.NameF.blank?) ? '' : customer.NameF
  end
  
  def last_name
    (customer.blank? or customer.NameL.blank?) ? '' : customer.NameL
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_name_and_course
    "#{first_name} #{last_name} - #{course.name}"
  end
  
  def full_name_with_check_in_status
    "#{first_name} #{last_name} (#{checkin_status})"
  end
  
  def full_name_with_rank
    "#{first_name} #{last_name} (#{acronym})"
  end
  
  def cell_phone_number
    customer.blank? ? '' : customer.PhoneMobile
  end
  
  def email
    customer.blank? ? '' : customer.Email
  end
  
#  def customer
#    Customer.where(CustomerID: self.CustomerID).first
#  end
  
  def account
#    customer.account unless customer.blank?
    Account.where(CustomerID: self.CustomerID, CompanyNumber: self.ClubCompanyNbr).first
  end
  
  def transactions
    account.transactions
  end
  
  def withdrawals
    unless account.blank?
      account.withdrawals 
    else
      return []
    end
  end
  
  def balance
    unless account.blank? or account.Balance.blank?
      return account.Balance
    else
      return 0
    end
  end
  
  def available_balance
    # If the account minimum balance is nil, set to zero
    unless account.blank? or account.MinBalance.blank?
      account_minimum_balance = account.MinBalance
      account_balance = account.Balance - account_minimum_balance
    else
      account_balance = 0
    end
    # The account available balance is the balance minus the minimum balance
    
    return account_balance
    
  end
  
  def minimum_balance
    unless account.blank? or account.MinBalance.blank?
      return account.MinBalance
    else
      0
    end
  end
  
  def vendor_payable
#    customer.vendor_payables.where(CompanyNbr: self.ClubCompanyNbr).first
    VendorPayable.where(CompanyNbr: self.ClubCompanyNbr, CustID: self.CustomerID).first
  end
  
  def holds_balance?
    balance > 0
  end
  
  def acronym
    caddy_rank_desc.acronym unless caddy_rank_desc.blank?
  end
  
  def rank_description
    caddy_rank_desc.description unless caddy_rank_desc.blank?
  end
  
  def checkin_time_today
    if checkin_today?
      self.CheckedIn
    end
  end
  
  def checkin_today?
    unless self.CheckedIn.blank?
      self.CheckedIn.today? 
    else
      false
    end
  end
  
  def checkin_status
    if checkin_today?
      "In"
    else
      "Out"
    end
  end
  
  def inactive?
    not active?
  end
  
  def average_rating
    unless caddy_ratings.blank?
      caddy_ratings.sum(:score) / caddy_ratings.size.round(2)
    else
      0
    end
  end
  
  def average_appearance_rating
    unless caddy_ratings.blank?
      caddy_ratings.sum(:appearance_score) / caddy_ratings.size.round(2)
    else
      0
    end
  end
  
  def average_enthusiasm_rating
    unless caddy_ratings.blank?
      caddy_ratings.sum(:enthusiasm_score) / caddy_ratings.size.round(2)
    else
      0
    end
  end
  
  def send_sms_notification(message_body)
    unless cell_phone_number.blank?
      SendCaddySmsWorker.perform_async(cell_phone_number, id, self.CustomerID, self.ClubCompanyNbr, message_body)
    end
  end
  
  def send_verification_code
    unless cell_phone_number.blank?
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      client.call(:send_sms, message: { Phone: cell_phone_number, Msg: "Your verification code is: #{pin}"})
    end
  end
  
  def account_transfers
    Transfer.where(to_account_id: account.id).or(Transfer.where(from_account_id: account.id)) unless account.blank?
  end
  
#  def company
#    course.company unless course.blank?
#  end

  def generate_pin
    self.pin = rand(0000..9999).to_s.rjust(4, "0")
    save
  end
  
  #############################
  #     Class Methods         #
  #############################
  
end
