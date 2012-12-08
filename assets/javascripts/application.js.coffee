# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#= require jquery
#= require_tree .
$.ready ->
  $(".add_new #add").click ->
    $.forms['add'].submit()
    true