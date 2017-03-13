class SendCaddyNewRoundNotificationSmsWorker
  include Sidekiq::Worker

  def perform(player_id)
    player = Player.where(id: player_id).first
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    client.call(:send_sms, message: { Phone: player.caddy.cell_phone_number, Msg: "Hey #{player.caddy.first_name}, you have a new round at #{player.club.CourseName} with #{player.member.full_name} at #{player.event.start.strftime('%I:%M%p')}!"})
  end
  
end
