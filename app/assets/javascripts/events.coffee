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
      $(this).closest("form").find('#player_total_amount').html '$' + sum
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
      return
    $('.caddy_fee_field').on 'keyup touchend', ->
      caddy_fee = $(this).val()
      caddy_tip = $(this).closest('form').find('#transfer_caddy_tip').val()
      
      if caddy_tip > 0 && caddy_fee > 0
        sum = parseFloat(caddy_fee) + parseFloat(caddy_tip)
      else if caddy_tip > 0 || caddy_fee > 0
        if caddy_fee > 0
          sum = parseFloat(caddy_fee)
        else if caddy_tip > 0
          sum = parseFloat(caddy_tip)
      else
        sum = 0
      $(this).closest("form").find('#transfer_amount').val sum
      $(this).closest("form").find('#player_total_amount').html '$' + sum
      # Add up all the amounts
      $('.amount').each ->
        sum += Number($(this).val())
        return
      # Add up all the transaction fees
      $('.transaction_fee').each ->
        sum += Number($(this).val())
        return
      $('#player_total').text '$' + sum.toFixed(2)
      return

  ### Add everything up on page load to make sure everything is correct ###
  $(document).on 'turbolinks:load', ->
    $('.transfer_tip_field').each ->
      caddy_fee = parseFloat($(this).closest('tr').find('#transfer_caddy_fee:first').val())
      caddy_tip = parseFloat($(this).closest('tr').find('#transfer_caddy_tip:first').val())
      sum = caddy_fee + caddy_tip
      $(this).closest('tr').find('#transfer_amount:first').val sum
      return
    $('.tip_field').each ->
      caddy_fee = parseFloat($(this).closest('form').find('#transfer_caddy_fee').val())
      caddy_tip = parseFloat($(this).closest('form').find('#transfer_caddy_tip').val())
      sum = caddy_fee + caddy_tip
      $(this).closest("form").find('#transfer_amount').val sum
      $(this).closest("form").find('#player_total_amount').text '$' + sum.toFixed(2)
      return
    total = 0
    # Add up all the amounts to show all players total at top of admin page
    $('.amount').each ->
      total += Number($(this).val())
      return
    # Add up all the transaction fees
    $('.transaction_fee').each ->
      total += Number($(this).val())
      return
    $('#player_total').text '$' + total.toFixed(2)

  ### Edit in place ###
  # turn to inline mode
  $.fn.editable.defaults.mode = 'inline';

  # Edit in place caddy tip
  $(document).on 'turbolinks:load', ->
    # Select/highlight value automatically
    $('.tip').on 'shown', (ev, editable) ->
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
        if value > 999
          return 'Must be less than $1000.'
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
    $('.caddy_fee').on 'shown', (ev, editable) ->
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
    $('.transaction_fee').on 'shown', (ev, editable) ->
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

  ### Pay Caddy Confirmation Details###
  $(document).on 'turbolinks:load', ->
    $('#players').on 'click', '.caddy_payment_button', (e) ->
      #user click on caddy pay button
      round = $(this).closest('form').find('#round:first').val()
      type = $(this).closest('form').find('#caddy_type:first').val()
      member_name = $(this).closest('form').find('#member_name:first').val()
      amount = Number($(this).closest('form').find('#transfer_amount:first').val())
      confirm1 = confirm('Are you sure you want to charge ' + member_name + ' $' + amount.toFixed(2) + ' for ' + round + ' ' + type + '?' )
      if confirm1
        return
      else
        e.preventDefault()
        return
  ### End Pay Caddy Confirmation Details ###

  