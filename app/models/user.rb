class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
       
  belongs_to :company
  
  #############################
  #     Instance Methods      #
  #############################
  
  def clubs
    company.clubs
  end
  
  def members
    company.members
  end
  
  def caddies
    company.caddies
  end
  
  #############################
  #     Class Methods         #
  #############################
end
