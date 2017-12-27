class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
       
  belongs_to :company
  has_many :caddy_ratings
  
  ROLES = %w[admin member caddy].freeze
#  validates_presence_of :role, :message => 'Please select type of user.'
  
  #############################
  #     Instance Methods      #
  #############################
  
  def courses
    company.courses
  end
  
  def members
    company.members
  end
  
  def caddies
    company.caddies
  end
  
  def caddy_pay_rates
    company.caddy_pay_rates
  end
  
  def caddy_rank_descs
    company.caddy_rank_descs
  end
  
  def not_admin?
    not admin?
  end
  
  def caddy
    Caddy.all.joins(:customer).where("customer.Email = ?", email).first
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
  
  #############################
  #     Class Methods         #
  #############################
end
