class CaddyRating < ApplicationRecord
  belongs_to :caddy
  belongs_to :user
  belongs_to :player
  
  def member
    player.member
  end
end
