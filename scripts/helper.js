function hideAllContaining(element) {
    var elements = $('[data-instid="'+element+'"]');
    $.each(elements, function(idx, val) {
        var parent = $(val).closest('.tracebody');
        $(parent).addClass( "hide");
    });
};

$(document).ready(function(){
    $('.path-element').dblclick(function() {
        hideAllContaining($(this).attr('data-instid'))
    });
});
