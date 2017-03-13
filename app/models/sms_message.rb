class SmsMessage < ApplicationRecord
  
  belongs_to :caddy
  belongs_to :customer
end
