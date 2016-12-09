json.extract! player, :id, :member_id, :caddy_id, :event_id, :caddy_type, :fee, :tip, :created_at, :updated_at
json.url player_url(player, format: :json)