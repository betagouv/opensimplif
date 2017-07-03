function copyChampValueToCommentField(){
    $("#copy_champ_value button").on('click', function(){
        $('#modalCommentairesDossierParChamp .wysihtml5-sandbox').contents().find('body').html($.trim($("#champ #value").html()));
    });
}