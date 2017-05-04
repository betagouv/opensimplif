class Backoffice::PrivateFormulairesController < ApplicationController
  before_action :authenticate_gestionnaire!

  def update
    dossier = Dossier.find(params[:dossier_id])

    if params[:champs]
      champs_service_errors = ChampsService.save_formulaire dossier.champs_private, params

      if champs_service_errors.empty?
        flash.notice = 'Formulaire enregistré'
      else
        flash.alert = champs_service_errors.map { |e| e[:message] }.join('<br>')
      end
    end

    render 'backoffice/dossiers/formulaire_private', formats: :js
  end
end
