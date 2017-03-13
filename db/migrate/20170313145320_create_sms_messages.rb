class CreateSmsMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :sms_messages do |t|
      t.string :to
      t.text :body
      t.integer :customer_id
      t.integer :caddy_id

      t.timestamps
    end
  end
end
