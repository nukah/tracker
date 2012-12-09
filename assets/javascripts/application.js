#= require jquery
#= require bootstrap
#= require_self
$(document).ready(function() {
  $("#add").click(function(e) {
    e.preventDefault();
    $.ajax({
      type: 'PUT',
      url: '/add',
      data: $("#add_new").serialize()
    });
  })
});