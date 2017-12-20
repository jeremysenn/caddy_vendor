class AddCaddyBooleanToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :caddy, :boolean, default: false
  end
end
