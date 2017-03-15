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

  $('.member_select').select2 theme: 'bootstrap'