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
function update(id) {
    var post = $("[data-id="+id+"]");
    $.ajax({
        url: "/update",
        type: "GET",
        async: 'false',
        data: {
            id: id,
         },
    });
}

function refresh(id) {
    var post = $("[data-id="+id+"]");
    $.ajax({
        url: "/refresh",
        type: "GET",
        data: {
            id: id,
         },
    }).success(function(obj) {
        $(post).animate({ opacity: 'toggle' }, 800, function() { 
            $(this).replaceWith(obj); success("Объект {0} был успешно обновлён.".format(id)) 
        });
    });
}


var emitter = new EventSource('/poll');
emitter.addEventListener('update', updateBlock, false);
function updateBlock(e) {
    refresh(e.data);
}
//emitter.addEventListener('update', updateBlock, false);
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
        update($(this).parent().data('id'));
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