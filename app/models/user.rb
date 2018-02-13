class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :validatable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable
       
  belongs_to :company
  has_many :caddy_ratings
  belongs_to :customer
  
  ROLES = %w[admin member caddy].freeze
#  validates_presence_of :role, :message => 'Please select type of user.'
  
  after_save :set_company_id, :unless => :company_id
  
  before_create do |user|
    user.verification_code = rand(100000..999999).to_s
  end
  before_create :set_role_and_customer_id
  
  after_commit :send_verification_code, on: [:create]
  
  validates :email, uniqueness: {allow_blank: false}
  
  
  #############################
  #     Instance Methods      #
  #############################
  
#  def courses
#    company.courses
#  end
  
#  def courses
#    user_courses = []
#    caddies.each do |caddy|
#      user_courses = user_courses << caddy.course unless caddy.course.blank?
#    end
#    return user_courses
#  end
#  
#  def courses_by_club(company_id)
#    user_courses = []
#    caddies_by_club(company_id).each do |caddy|
#      user_courses = user_courses << caddy.course unless caddy.course.blank?
#    end
#    return user_courses
#  end
  
  def members
    company.members
  end
  
#  def caddies
#    company.caddies
#  end

#  def caddies
##    unless caddy_customer.blank?
##      caddy_customer.caddies
##    end
#    user_caddies = []
#    caddy_customers.each do |customer|
#      customer.caddies.each do |caddy|
#        user_caddies = user_caddies << caddy
#      end
#    end
#    return user_caddies
#  end
  
  def caddies_by_club(company_id)
    user_caddies = []
    caddies.where(ClubCompanyNbr: company_id).each do |caddy|
      user_caddies << caddy
    end
    return user_caddies
  end
  
  def caddy_pay_rates
    company.caddy_pay_rates
  end
  
  def caddy_rank_descs
    company.caddy_rank_descs
  end
  
  def not_admin?
    not is_admin?
  end
  
  def caddy
    # Find caddy by customer phone number
    caddy_record = Caddy.all.joins(:customer).where("customer.PhoneMobile = ?", phone).first
    if caddy_record.blank?
      # If can't find customer record by phone number, find by email
      caddy_record = Caddy.all.joins(:customer).where("customer.Email = ?", email).first
    end
    return caddy_record
  end
  
#  def caddies
#    # Find caddies by customer phone number
#    caddy_records = Caddy.all.joins(:customer).where("customer.PhoneMobile = ?", phone)
#    if caddy_records.blank?
#      # If can't find customer record by phone number, find by email
#      caddy_records = Caddy.all.joins(:customer).where("customer.Email = ?", email)
#    end
#    return caddy_records
#  end

  def caddies
    customer.caddies unless customer.blank?
  end
  
  def unique_caddy_clubs
    clubs = []
    caddies.each do |caddy|
      unless clubs.include?(caddy.company)
        clubs << caddy.company
      end
    end
    return clubs
  end
  
#  def caddy_customer(company_id)
#    Customer.caddies.where(Email: email, CompanyNumber: company_id).first
#  end
  
  def caddy_customer
    customer
    # Find customer by phone number
    customer_record = Customer.caddies.find_by(PhoneMobile: phone)
    if customer_record.blank?
      # If can't find customer record by phone number, find by email
      customer_record = Customer.caddies.find_by(Email: email)
    end
    return customer_record
  end
  
  def caddy_customers
    # Find customers by phone number
    customer_records = Customer.caddies.where(PhoneMobile: phone)
    if customer_records.blank?
      # If can't find customers by phone number, find by email
      customer_records = Customer.caddies.where(Email: email)
    end
    return customer_records
  end
  
  def member
    customer
    # Find customer by phone number
#    customer_record = Customer.members.find_by(PhoneMobile: phone)
#    if customer_record.blank?
#      # If can't find customer record by phone number, find by email
#      customer_record = Customer.members.find_by(Email: email)
#    end
#    return customer_record
  end
  
#  def customer
#    if is_member?
#      member
#    elsif is_caddy?
#      caddy_customer
#    end
#  end
  
  def is_member?
    role == 'member'
  end
  
  def is_caddy?
    role == 'caddy'
  end
  
  def is_admin?
    role == 'admin'
  end
  
  def set_company_id
    if is_caddy? and not caddy.blank?
      self.update_attribute(:company_id, caddy.ClubCompanyNbr)
    elsif is_member? and not member.blank?
      self.update_attribute(:company_id, member.CompanyNumber)
    end
  end
  
  def ezcash_send_mms_cust_barcode_web_service_call
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    customer_record = customer
    unless customer_record.blank?
      response = client.call(:send_mms_cust_barcode, message: { CustomerID: customer_record.id, CompanyNumber: company_id})
      Rails.logger.debug "Response body: #{response.body}"
      if response.success?
        unless response.body[:send_mms_cust_barcode_response].blank? or response.body[:send_mms_cust_barcode_response][:return].blank?
          return response.body[:send_mms_cust_barcode_response][:return]
        else
          return nil
        end
      else
        return nil
      end
    else
      return nil
    end
  end
  
  def send_verification_code
    unless phone.blank?
      client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
      client.call(:send_sms, message: { Phone: phone, Msg: "#{verification_code} is your CaddyVend verification code."})
    end
  end
  
  def phone_verified?
    verification_code.blank?
  end
  
  def set_role_and_customer_id
    customer_record = Customer.find_by(PhoneMobile: phone)
    unless customer_record.blank?
      self.customer_id = customer_record.id
      if customer_record.member?
        self.role= "member"
      elsif customer_record.caddy?
        self.role= "caddy"
      else
        self.role= "admin"
      end
    end
  end
  
  #############################
  #     Class Methods         #
  #############################
end
