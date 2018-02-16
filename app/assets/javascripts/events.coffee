# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

jQuery ->
  $(document).on 'turbolinks:load', ->
    $('.tip_field').on 'keyup touchend', ->
      caddy_fee = $(this).closest('form').find('#transfer_caddy_fee').val()
      caddy_tip = $(this).val()
      #transaction_fee = $(this).closest('.modal').find('#transfer_fee').val()
      if caddy_tip > 0
        sum = parseFloat(caddy_fee) + parseFloat(caddy_tip)
      else
        sum = parseFloat(caddy_fee)
      $(this).closest("form").find('#transfer_amount').val sum
      $(this).closest("form").find('#player_total').html '$' + sum
      return

  ### Edit in place ###
  # turn to inline mode
  $.fn.editable.defaults.mode = 'inline';

  # Edit in place caddy tip
  $(document).on 'turbolinks:load', ->
    # Select value automatically
    $('.tip').editable().on 'shown', (ev, editable) ->
      setTimeout (->
        editable.input.$input.select()
        return
      ), 0
      return

    $('#players').editable
      selector: '.tip'
      tpl: "<input type='text' style='width: 75px'>"
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
        if value > 99
          return 'Must be less than $100.'
        return
      success: (response, newValue) ->
        if response.status == 'error'
          return response.msg
        caddy_tip = parseFloat(newValue)
        caddy_fee = parseFloat($(this).closest('tr').find('#transfer_caddy_fee:first').val())
        $(this).closest('tr').find('#transfer_caddy_tip:first').val caddy_tip
        $(this).closest('tr').find('#transfer_amount:first').val caddy_fee + caddy_tip
        sum = 0
        # Add up all the amounts
        $('.amount').each ->
          sum += Number($(this).val())
          return
        # Add up all the transaction fees
        $('.transaction_fee').each ->
          sum += Number($(this).val())
          return
        $('#player_total').text '$' + sum.toFixed(2)
        #msg will be shown in editable form
        return

    # Edit in place caddy fee

    # Select value automatically
    $('.caddy_fee').editable().on 'shown', (ev, editable) ->
      setTimeout (->
        editable.input.$input.select()
        return
      ), 0
      return

    $('#players').editable
      selector: '.caddy_fee'
      tpl: "<input type='text' style='width: 75px'>"
      title: 'Caddy Fee'
      name: 'caddy fee'
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
        if ! $.isNumeric(value) or value <= 0
          return 'Must be greater than zero.'
        if value > 999
          return 'Must be less than $1000.'
        return
      success: (response, newValue) ->
        if response.status == 'error'
          return response.msg
        caddy_fee = parseFloat(newValue)
        caddy_tip = parseFloat($(this).closest('tr').find('#transfer_caddy_tip:first').val())
        $(this).closest('tr').find('#transfer_caddy_fee:first').val caddy_fee
        $(this).closest('tr').find('#transfer_amount:first').val caddy_fee + caddy_tip
        sum = 0
        # Add up all the amounts
        $('.amount').each ->
          sum += Number($(this).val())
          return
        # Add up all the transaction fees
        $('.transaction_fee').each ->
          sum += Number($(this).val())
          return
        $('#player_total').text '$' + sum.toFixed(2)
        #msg will be shown in editable form
        return  

    # Edit in place transaction fee

    # Select value automatically
    $('.transaction_fee').editable().on 'shown', (ev, editable) ->
      setTimeout (->
        editable.input.$input.select()
        return
      ), 0
      return

    $('#players').editable
      selector: '.transaction_fee'
      tpl: "<input type='text' style='width: 75px'>"
      title: 'Transaction Fee'
      name: 'transaction fee'
      ajaxOptions: 
        type: 'put'
        dataType: 'json'
      validate: (value) ->
        if $.trim(value) == ''
          return 'This field is required'
        if ! $.isNumeric(value) or value < 0
          return 'Must be a positive number'
        if value > 199
          return 'Must be less than $200.'
        return
      success: (response, newValue) ->
        #if response.status == 'error'
        #  return response.msg
        transaction_fee = parseFloat(newValue)
        $(this).closest('tr').find('#transfer_fee:first').val transaction_fee
        sum = 0
        # Add up all the amounts
        $('.amount').each ->
          sum += Number($(this).val())
          return
        # Add up all the transaction fees
        $('.transaction_fee').each ->
          sum += Number($(this).val())
          return
        $('#player_total').text '$' + sum.toFixed(2)
        #msg will be shown in editable form
        return  

    return
  ### End Edit in place ###

  #$('.tip_field').on 'click', ->
  #  # Select tip input field contents
  #  $(this).select()
  #  return

  #$('.tip_field').on 'click touchend', ->
    # Select tip input field contents
  #  $(this).select()
  #  return

  $('.tip_field').on 'click', ->
    # Select tip input field contents
    #$(this).select()
    $(this).setSelectionRange(0, this.value.length)
    return

  