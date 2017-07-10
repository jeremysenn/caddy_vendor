class SmsMessage < ApplicationRecord
  
  belongs_to :caddy
  belongs_to :customer
  belongs_to :company
  
end
