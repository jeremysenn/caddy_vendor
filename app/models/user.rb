class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
       
  belongs_to :company
  has_many :caddy_ratings
  
  ROLES = %w[admin member caddy].freeze
  validates_presence_of :role, :message => 'Please select type of user.'
  
  after_save :set_company_id, :unless => :company_id
  
  #############################
  #     Instance Methods      #
  #############################
  
  def courses
    company.courses
  end
  
  def members
    company.members
  end
  
#  def caddies
#    company.caddies
#  end

  def caddies
    unless caddy_customer.blank?
      caddy_customer.caddies
    end
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
    Caddy.all.joins(:customer).where("customer.Email = ?", email).first
  end
  
  def caddy_customer
    Customer.caddies.where(Email: email).first
  end
  
  def member
    Customer.members.where(Email: email).first
  end
  
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
  
  #############################
  #     Class Methods         #
  #############################
end
