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

$(document).ready(function() {
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
       var o = $(this).parents('.box');
       $.ajax({
           url: "/update",
           type: "POST",
           data: {
             id: o.data('id'),
           },
       }).success(function(d) {
           o.fadeOut('fast', function() { $(d).hide(); o.replaceWith(d); o.fadeIn('slow');});
       });
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

$(function poll() { 
    $.ajax({ 
        url: "/i", 
        dataType: "json", 
        complete: poll, 
        timeout: 30000,
        success: function(data) {
            console.log(data);
        },
    });
});