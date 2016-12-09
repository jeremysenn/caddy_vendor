class Club < ApplicationRecord
  belongs_to :user
  has_many :events
  has_and_belongs_to_many :members
  has_and_belongs_to_many :caddies
end
