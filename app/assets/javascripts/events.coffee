# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $('.tip_field').on 'keyup', ->
    caddy_fee = $(this).closest('.modal').find('#transfer_caddy_fee').val()
    caddy_tip = $(this).val()
    if caddy_tip > 0
      sum = parseFloat(caddy_fee) + parseFloat(caddy_tip)
    else
      sum = parseFloat(caddy_fee)
    $(this).closest(".modal").find('#transfer_amount').val sum
    return