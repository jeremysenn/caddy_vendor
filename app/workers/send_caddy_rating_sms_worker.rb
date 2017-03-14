class SendCaddyRatingSmsWorker
  include Sidekiq::Worker

  def perform(transfer_id)
    transfer = Transfer.where(id: transfer_id).first
    client = Savon.client(wsdl: "#{ENV['EZCASH_WSDL_URL']}")
    client.call(:send_sms, message: { Phone: transfer.member.phone, Msg: "Hi #{transfer.member.first_name}, please rate your caddy by going here: #{Rails.application.routes.url_helpers.new_caddy_rating_url(player_id: transfer.player.id)}"})
  end
  
end
