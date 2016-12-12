class Entity < ActiveRecord::Base
  self.primary_key = 'EntityID'
  self.table_name= 'Entities'
  
  establish_connection :ez_cash
  
  after_commit :create_corresponding_payment_entity_account_type, :on => :create, :if => (:persisted? and :payment?)
  
  attr_accessor :type
  
  #############################
  #     Instance Methods      #
  #############################
  
  def name
    self.EntityName
  end
  
  def entity_account_type
    EntityAccountType.find_by_EntityID(id)
  end
  
  def account_type
    AccountType.find(entity_account_type.AccountTypeID) unless entity_account_type.blank?
  end
  
  def account_type_description
    account_type.AccountTypeDesc unless account_type.blank?
  end
  
  def payment_entity?
    account_type.AccountTypeID == 4 unless account_type.blank?
  end
  
  def address
    "#{self.EntityAddressL1} #{self.EntityCity} #{self.EntityState}"
  end
  
  def active?
    self.Active == 1
  end
  
  def payment?
    type == "payment"
  end
  
  def customer
    Customer.find_by_CustomerID(self.OwningCustomerID) unless self.OwningCustomerID.blank?
  end
  
  def all_information_blank?
    self.EntityAddressL1.blank? and self.EntityAddressL2.blank? and self.EntityCity.blank? and self.EntityState.blank? and self.EntityZip.blank? and 
      self.EntityCountry.blank? and self.EntityPhone.blank? and self.EntityContactPhone.blank?
  end
  
  def create_corresponding_payment_entity_account_type
    try
    EntityAccountType.create(EntityID: self.EntityID, AccountTypeID: 4, CreateDate: Time.now)
  end
  
  def accounts
    Account.where(EntityID: self.EntityID)
  end
  
  #############################
  #     Class Methods      #
  #############################
  
  def self.payment_entities
    Entity.select { |entity| entity.payment_entity? }
  end
  
end
