class AddPinToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :pin, :integer
  end
end
