function copy_champ_value(){
    $("#copy_champ_value button").on('click', function(){
        $('.wysihtml5-sandbox').contents().find('body').html($.trim($("#champ #value").html()));
    });
}