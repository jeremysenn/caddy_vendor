class Caddy < ApplicationRecord
#  self.primary_key = 'CustomerID'
  self.table_name= 'Caddies'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "ClubCompanyNbr"
#  belongs_to :course, :foreign_key => "ClubCompanyNbr"
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
    customer.account unless customer.blank?
  end
  
  def balance
    # If the account minimum balance is nil, set to zero
    account_minimum_balance = account.MinBalance || 0
    # The account available balance is the balance minus the minimum balance
    account_balance = account.Balance - account_minimum_balance
    return account_balance
    
#    # Get the lesser of vendor payable and account balance
#    vp = vendor_payable
#    unless vp.blank?
#      vendor_payable_balance = vp.Balance
#      # The account available balance is the balance minus the minimum balance
#      account_balance = account.Balance - account_minimum_balance
#      # Get the lesser of the two balances
#      if vendor_payable_balance <= account_balance
#        return vendor_payable_balance
#      else
#        return account_balance
#      end
#    else
#      return 0
#    end

  end
  
  def vendor_payable
#    customer.vendor_payables.where(CompanyNbr: self.ClubCompanyNbr).first
    VendorPayable.where(CompanyNbr: self.ClubCompanyNbr, CustID: self.CustomerID).first
  end
  
  def holds_balance?
    balance != 0
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
      SendCaddySmsWorker.perform_async(cell_phone_number, id, self.CustomerID, self.course.ClubCompanyNumber, message_body)
    end
  end
  
  def account_transfers
    Transfer.where(to_account_id: account.id).or(Transfer.where(from_account_id: account.id)) unless account.blank?
  end
  
#  def company
#    course.company unless course.blank?
#  end
  
  #############################
  #     Class Methods         #
  #############################
  
end
