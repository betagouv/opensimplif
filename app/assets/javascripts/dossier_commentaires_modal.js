$(document).on('page:load', initModalCommentaire);
$(document).ready(initModalCommentaire);

function initModalCommentaire() {
    var modal = $("#modalCommentairesDossierParChamp");
    var body = modal.find(".modal-body");
    var originalBody = body.html();

    modal.on("show.bs.modal", function (e) {
        var modalUrl = $(e.relatedTarget).data('href');
        body.load(modalUrl, displayModalContentComplete());
    });

    modal.on("shown.bs.modal", function (e) {
        copyChampValueToCommentField();
        activateWysihtml5InDiv('#modalCommentairesDossierParChamp');
    });

    modal.on("hidden.bs.modal", function (e) {
        body.html(originalBody);
    });
}

function refreshModalCommentaire(modalUrl) {
    $("#modalCommentairesDossierParChamp .modal-body").load(modalUrl, displayModalContentComplete());
}

function displayModalContentComplete() {
    copyChampValueToCommentField();
    activateWysihtml5InDiv('#modalCommentairesDossierParChamp');
}
