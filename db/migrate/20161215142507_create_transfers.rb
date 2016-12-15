class CreateTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :transfers do |t|
      t.integer :from_account_id
      t.integer :to_account_id
      t.integer :customer_id
      t.integer :player_id
      t.integer :caddy_fee_cents
      t.integer :caddy_tip_cents
      t.integer :amount_cents
      t.integer :fee_cents

      t.timestamps
    end
  end
end
