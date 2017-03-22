class ChangeTransferClubIdToCompanyId < ActiveRecord::Migration[5.0]
  def change
    rename_column :transfers, :club_id, :company_id
  end
end
