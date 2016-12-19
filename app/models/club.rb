class Club < ApplicationRecord
  self.primary_key = 'ClubCourseID'
  self.table_name= 'CaddyCourses'
  
  establish_connection :ez_cash
  
  belongs_to :company, :foreign_key => "ClubCompanyNumber"
  has_many :events
  has_many :caddies, :foreign_key => "ClubCompanyNbr"
#  has_and_belongs_to_many :members
#  has_and_belongs_to_many :caddies

  #############################
  #     Instance Methods      #
  #############################
  
  def name
    self.CourseName
  end
  
  #############################
  #     Class Methods         #
  #############################
end
