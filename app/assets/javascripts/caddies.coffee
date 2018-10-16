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

  $(document).on 'turbolinks:before-cache', ->
    $('.member_select').select2 'destroy'
    $('caddy_customers_select').select2 'destroy'
    return
  $(document).on 'turbolinks:load', ->
    $('.member_select').select2 theme: 'bootstrap'
    $('.caddy_customers_select').select2
      theme: 'bootstrap'
      minimumInputLength: 3
    return
  
  ### Send caddy verification code ###
  #$(document).on "turbolinks:load", ->
  #  $('#send_caddy_verification_code').on 'click', ->
  #    caddy_id = $(this).data( "caddy-id" )
  #    #alert caddy_id
  #    $.ajax
  #      url: "/caddies/" + caddy_id + "/send_verification_code"
  #      dataType: 'json'
  #      success: (data) ->
  #        return
  #      error: ->
  #        $('#sms_payment_verification').modal('toggle')
  #        alert 'There was a problem sending the verification code'
  #        return

  $(document).on "turbolinks:load", ->
    $('a[data-toggle="tab"]').on 'show.bs.tab', (e) ->
      #save the latest tab
      localStorage.setItem 'lastTab', $(e.target).attr('href')
      return
    #go to the latest tab, if it exists:
    lastTab = localStorage.getItem('lastTab')
    if lastTab
      $('a[href="' + lastTab + '"]').click()
    return

  ### Pay Caddy Confirmation Details###
  $(document).on 'turbolinks:load', ->
    $('#pay_caddy_by_member_form').on 'click', '#pay_by_member_button', (e) ->
      #user click on caddy pay button
      member_name = $(this).closest('form').find('#member_id:first option:selected').text()
      amount = Number($(this).closest('form').find('#amount:first').val())
      if member_name == "-- Select member --"
        e.preventDefault()
        alert 'Please choose a member.'
        return
      else if (!$.isNumeric(amount) || amount <= 0)
        e.preventDefault()
        alert 'Amount must be a positive number.'
        return
      else 
        confirm1 = confirm('Are you sure you want to charge ' + member_name + ' $' + amount.toFixed(2) + '?' )
        if confirm1
          return
        else
          e.preventDefault()
          return
  ### End Pay Caddy Confirmation Details ###

    