$(document).ready(activateWysihtml5);
$(document).on('page:load', activateWysihtml5);

function activateWysihtml5(){
    activateWysihtml5InDiv('body');
}

function activateWysihtml5InDiv(wrapperId){
    $(wrapperId + ' .wysihtml5').each(function(i, elem) {
        $(elem).wysihtml5({ toolbar:{ "fa": true, "link": false, "color": true }, "locale": "fr-FR" });
    });
    replaceColorStylesWithInlineCss();
}

replaceColorStylesWithInlineCss = function (){
    $(".wysiwyg-color-black").css('color','black');
    $(".wysiwyg-color-silver").css('color','silver');
    $(".wysiwyg-color-gray").css('color','gray');
    $(".wysiwyg-color-maroon").css('color','maroon');
    $(".wysiwyg-color-red").css('color','red');
    $(".wysiwyg-color-purple").css('color','purple');
    $(".wysiwyg-color-green").css('color','green');
    $(".wysiwyg-color-olive").css('color','olive');
    $(".wysiwyg-color-navy").css('color','navy');
    $(".wysiwyg-color-blue").css('color','blue');
    $(".wysiwyg-color-orange").css('color','orange');
};