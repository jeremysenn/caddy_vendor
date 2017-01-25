class AddMoreScoresAndPlayerIdToCaddyRatings < ActiveRecord::Migration[5.0]
  def change
    add_column :caddy_ratings, :player_id, :integer
    add_column :caddy_ratings, :appearance_score, :integer, default: 0
    add_column :caddy_ratings, :enthusiasm_score, :integer, default: 0
  end
end
