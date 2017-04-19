date_format = event.all_day_event? ? '%Y-%m-%d' : '%Y-%m-%dT%H:%M:%S'

json.id event.id
json.title event.player_names_with_caddy_names
json.start event.start.strftime(date_format)
json.end event.end.strftime(date_format)

json.color event.color unless event.color.blank? or event.not_paid?
json.allDay event.all_day_event? ? true : false

json.status event.status

json.course_id event.course

json.update_url event_path(event, method: :patch)
json.edit_url edit_event_path(event)