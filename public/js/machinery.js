String.prototype.format = function() {
  var args = arguments;
  return this.replace(/{(\d+)}/g, function(match, number) { 
    return typeof args[number] != 'undefined'
      ? args[number]
      : match
    ;
  });
};
function success(message) {
    return noty({
        "text": message,
        "theme":"noty_theme_twitter",
        "layout":"topRight",
        "type":"success",
        "animateOpen":{"opacity":"toggle"},
        "animateClose":{"height":"toggle"},
        "speed":200,
        "timeout":2000,
        "closeButton":false,
        "closeOnSelfClick":true,
        "closeOnSelfOver":false,
        "modal":false});
}

function fail(message) {
    return noty({
        "text": message,
        "theme":"noty_theme_twitter",
        "layout":"topRight",
        "type":"error",
        "animateOpen":{"opacity":"toggle"},
        "animateClose":{"height":"toggle"},
        "speed":200,
        "timeout":2000,
        "closeButton":false,
        "closeOnSelfClick":true,
        "closeOnSelfOver":false,
        "modal":false});
}
function refresh(id) {
    var post = $("[data-id="+id+"]");
    $.ajax({
        url: "/update",
        type: "POST",
        data: {
            id: id,
         },
    }).success(function(obj) {
        $(post).animate({ opacity: 'toggle' }, 300, function() { $(this).replaceWith(obj); success("Объект {0} был успешно обновлён.".format(id)) });
        $(".updates").prepend("<p>{0} @ {1}</p>".format(id, (new Date().toLocaleString())))
    });
}
$(document).ready(function() {
    updateTrackings();
    
    $("#add_new_tid").live('click', function() {
        var tid = $('#tracking_id').attr('value');
        if(tid == '') {
            fail('Требуется правильный код трекинга');
        } else {
            $.ajax({
                url: "/",
                type: "POST",
                data: {
                    tid: $('#tracking_id').attr('value'),
                }
            }).success(function(d) {
                $('.warehouse').prepend(d).show();
                $('h2').fadeOut('fast');
                success("Объект "+tid+" успешно добавлен.");
            });
        }
    });
    
    $(".box .remove").live('click', function() {
       var o = $(this).parents('.box');
       $.ajax({
           url: "/delete",
           type: "POST",
           data: {
             id: o.data('id'),
           },
       }).success(function() {
           o.fadeOut('slow');
       });
    });
    
    $(".box .refresh").live('click', function() {
        refresh($(this).parent().data('id'));
    });
    
    
    $("#update_all_tid").live('click', function() {
        $.ajax({
            url: "/update",
            type: "POST",
        }).success(function() {
            success("Обновление успешно выполнено");
        }).fail(function(e,b) {
            fail("Ошибка при обновлении");
        });
    });
});
function updateTrackings() {
    $.ajax({
        type: 'GET',
        url: '/poll',
        dataType: 'json',
        data: { time: Math.round(new Date().getTime()/1000) },
        success: function(data, status) {
            $.each(data, function(i,v) {
                refresh(v);
            });
        }
    });
    setTimeout(updateTrackings, 10000);
}