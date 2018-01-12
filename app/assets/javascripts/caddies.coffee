# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).on "turbolinks:load", ->
    if !$('.rateit-range').length
      $('.rateit').rateit()

    ### Re-enable disabled_with buttons for back button ###
    $.rails.enableElement $('.caddy_spinner_button')
    return

  $(document).on "turbolinks:load", ->
    $('#select_all').click ->
      s = $(this)

      #if s.text() == 'Select all'
      if s.hasClass 'fa-square-o'
        #s.html 'Select none'
        s.toggleClass('fa-square-o fa-check-square-o')
        $('#' + $(this).attr('rel') + ' INPUT[type=\'checkbox\']').prop 'checked', true
        false
      else
        #s.html 'Select all'
        s.toggleClass('fa-square-o fa-check-square-o')
        $('#' + $(this).attr('rel') + ' INPUT[type=\'checkbox\']').prop 'checked', false
        false

      #s.html if s.text() == 'Select all' then 'Select none' else 'Select all'
      #$('#' + $(this).attr('rel') + ' INPUT[type=\'checkbox\']').attr 'checked', true

      return

  $('.member_select').select2 theme: 'bootstrap'

  
  ### Send caddy verification code ###
  $(document).on "turbolinks:load", ->
    $('#send_caddy_verification_code').on 'click', ->
      caddy_id = $(this).data( "caddy-id" )
      #alert caddy_id
      $.ajax
        url: "/caddies/" + caddy_id + "/send_verification_code"
        dataType: 'json'
        success: (data) ->
          return
        error: ->
          $('#sms_payment_verification').modal('toggle')
          alert 'There was a problem sending the verification code'
          return

    