class VendorPayable < ApplicationRecord
  
  establish_connection :ez_cash
  self.table_name= 'VendorPayables'
  
  belongs_to :customer, :foreign_key => "CustID"
  belongs_to :company, :foreign_key => "CompanyNbr"
  
  #############################
  #     Instance Methods      #
  #############################
  
  def caddy?
    customer.caddy? unless customer.blank?
  end
  
  def first_name
    customer.NameF unless customer.blank?
  end
  
  def last_name
    customer.NameL unless customer.blank?
  end
  
  def balance
    self.Balance
  end
  
  def time_stamp
    Time.now
  end
  
  #############################
  #     Class Methods         #
  #############################
  
  def self.to_csv
    require 'csv'
    attributes = %w{time_stamp first_name last_name balance}
    
    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |vendor_payable|
        csv << attributes.map{ |attr| vendor_payable.send(attr) }
      end
    end
  end
  
end
