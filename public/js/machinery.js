$(document).ready(function() {
    $('#add_new_tid').click(function() {
        if($('#tracking_id').attr('value') == '') {
            alert('Нужен номер трекинга');
        } else {
            $.ajax({
                url: "/",
                type: "POST",
                data: {
                    tid: $('#tracking_id').attr('value'),
                },
            }).success(function(data) {
                $('#listing tbody').fadeIn('slow').append(data);
            });
        }
    });
    
    $('.delete').click(function() {
       obj = $(this).parents('tr');
       $.ajax({
           url: "/",
           type: "DELETE",
           data: {
             id: $(this).data('id')
           },
       }).success(function() {
           obj.fadeOut('slow');
       });
    });
});