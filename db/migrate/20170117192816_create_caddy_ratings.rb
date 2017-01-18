class CreateCaddyRatings < ActiveRecord::Migration[5.0]
  def change
    create_table :caddy_ratings do |t|
      t.references :caddy, foreign_key: true
      t.references :user, foreign_key: true
      t.string :comment
      t.integer :score, default: 0

      t.timestamps
    end
  end
end
