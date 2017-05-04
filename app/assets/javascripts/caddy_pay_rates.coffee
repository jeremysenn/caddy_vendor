# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $(document).on 'turbolinks:load', ->
    # Apply select2 to existing player guest selects
    $('.caddy_type_select').select2
      #placeholder: 'Type'
      theme: 'bootstrap'
      tags: true
      multiple: false