class Member < ApplicationRecord
  has_and_belongs_to_many :clubs
  
  #############################
  #     Instance Methods      #
  #############################
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  #############################
  #     Class Methods         #
  #############################
end
