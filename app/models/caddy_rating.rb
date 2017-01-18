class CaddyRating < ApplicationRecord
  belongs_to :caddy
  belongs_to :user
end
