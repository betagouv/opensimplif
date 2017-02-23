$(document).on('page:load', init_modal_commentaire);
$(document).ready(init_modal_commentaire);

function init_modal_commentaire() {
    var modal = $("#modalCommentairesDossierParChamp");
    var body = modal.find(".modal-body");
    var originalBody = body.html();

    modal.on("show.bs.modal", function (e) {
        body.load(e.relatedTarget.getAttribute("data-href"));
    });

    $("#modalCommentairesDossierParChamp").on("hidden.bs.modal", function (e) {
        body.html(originalBody);
    });
}
