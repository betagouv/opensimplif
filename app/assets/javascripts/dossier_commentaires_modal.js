$(document).on('page:load', initModalCommentaire);
$(document).ready(initModalCommentaire);

function initModalCommentaire() {
    var modal = $("#modalCommentairesDossierParChamp");
    var body = modal.find(".modal-body");
    var originalBody = body.html();

    modal.on("show.bs.modal", function (e) {
        body.load(e.relatedTarget.getAttribute("data-href"));
    });

    modal.on("shown.bs.modal", function (e) {
        copyChampValueToCommentField();
        activateWysihtml5InDiv('#modalCommentairesDossierParChamp');
    });

    $("#modalCommentairesDossierParChamp").on("hidden.bs.modal", function (e) {
        body.html(originalBody);
    });
}
