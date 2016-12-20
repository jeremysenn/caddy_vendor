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

  ### Edit in place ###
  # turn to inline mode
  $.fn.editable.defaults.mode = 'inline';

  # Force all elements submit via PUT method
  # $.fn.editable.defaults.ajaxOptions = {type: "put"}
  $(document).on 'turbolinks:load', ->
    $('#players').editable
      selector: '.tip'

      title: 'Tip'
      name: 'tip'
      #placeholder: 'Required'
      #display: (value) ->
      #  $(this).text '$' + value
      #  return
      ajaxOptions: 
        type: 'put'
        dataType: 'json'
      validate: (value) ->
        if $.trim(value) == ''
          return 'This field is required'
        if ! $.isNumeric(value) or value < 0
          return 'Must be a positive number'
        return
      success: (response, newValue) ->
        if response.status == 'error'
          return response.msg
        caddy_fee = parseFloat($(this).closest('tr').find('#transfer_caddy_fee:first').val())
        caddy_tip = newValue
        $(this).closest('tr').find('#transfer_caddy_tip:first').val caddy_tip
        $(this).closest('tr').find('#transfer_amount:first').val caddy_fee + caddy_tip
        sum = 0
        $('.amount').each ->
          sum += Number($(this).val())
          return
        $('#player_total').text '$' + sum.toFixed(2)
        #msg will be shown in editable form
        return
    return
  return
  ### End Edit in place ###