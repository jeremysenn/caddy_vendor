class Caddy < ApplicationRecord
  self.primary_key = 'CustomerID'
  self.table_name= 'Caddies'
  
  establish_connection :ez_cash
  
#  has_and_belongs_to_many :clubs
  
  #############################
  #     Instance Methods      #
  #############################
  
  def first_name
    customer.blank? ? '' : customer.NameF
  end
  
  def last_name
    customer.blank? ? '' : customer.NameL
  end
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def customer
    Customer.where(CustomerID: self.CustomerID).first
  end
  
  #############################
  #     Class Methods         #
  #############################
end
