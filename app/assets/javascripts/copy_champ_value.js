function copyChampValueToCommentField(){
    $("#copy_champ_value button").on('click', function(){
        var $valueSelector = $("#commentaires_flux #value-wrapper-block");
        var $textareaSelector = $('#modalCommentairesDossierParChamp .wysihtml5-sandbox');
        var valueToCopy = $.trim($valueSelector.html());
        console.log($valueSelector.html());
        $textareaSelector.contents().find('body').html(valueToCopy);
    });
}