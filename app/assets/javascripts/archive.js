$(document).on('page:load', buttons_archived);
$(document).ready(buttons_archived);

function buttons_archived(){
    $("button#archive").on('click', function(){
        $("button#archive").hide();
        $("#confirm").show();
    });

    $("#confirm #cancel").on('click', function(){
        $("button#archive").show();
        $("#confirm").hide();
    });
}