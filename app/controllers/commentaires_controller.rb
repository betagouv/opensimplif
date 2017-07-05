class CommentairesController < ApplicationController
  def index
    @facade = DossierFacades.new(
      params[:dossier_id],
      (current_gestionnaire || current_user).email,
      params[:champs_id]
    )
    render layout: false
  rescue ActiveRecord::RecordNotFound
    flash.alert = t('errors.messages.dossier_not_found')
    redirect_to url_for(controller: '/')
  end

  def create
    @commentaire = Commentaire.new
    @commentaire.dossier = Dossier.find(params['dossier_id'])
    @commentaire.champ = @commentaire.dossier.champs.find(params[:champ_id]) if params[:champ_id]

    if gestionnaire?
      @commentaire.email = current_gestionnaire.email
      @commentaire.dossier.next_step! 'gestionnaire', 'comment'
    else
      @commentaire.email = current_user.email
      @commentaire.dossier.next_step! 'user', 'comment' if current_user.email == @commentaire.dossier.user.email
    end

    if params[:piece_justificative].present?
      commentaire_champ_libelle = @commentaire.champ.type_de_champ.libelle if @commentaire.champ
      pj = PiecesJustificativesService.upload_one! @commentaire.dossier, current_user, params, commentaire_champ_libelle

      if pj.errors.empty?
        @commentaire.piece_justificative = pj
      else
        flash.alert = pj.errors.full_messages.join('<br>').html_safe
      end
    end

    @commentaire.body = params['texte_commentaire']
    if @commentaire.body.blank? && @commentaire.piece_justificative.nil?
      flash.alert = 'Veuillez rédiger un message ou ajouter une pièce jointe.'
    elsif !flash.alert
      @commentaire.save
    end

    if gestionnaire? && !current_gestionnaire.follow?(@commentaire.dossier)
      current_gestionnaire.toggle_follow_dossier @commentaire.dossier
    end

    if pj || params[:champ_id].blank?
      redirect_to backoffice_dossier_path(@commentaire.dossier)
    else
      @modal_url = backoffice_dossier_commentaires_path(@commentaire.dossier, champs_id: params[:champ_id])
    end
  end

  def gestionnaire?
    false
  end
end
