class AddCompanyIdToSmsMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :sms_messages, :company_id, :integer
  end
end
