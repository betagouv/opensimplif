class Users::DescriptionController < UsersController
  before_action only: [:show] do
    authorized_routes? self.class
  end

  before_action :check_starter_dossier_informations, only: [:show]

  def show
    @dossier ||= current_user_dossier.decorate

    @procedure = @dossier.procedure
    @champs = @dossier.ordered_champs

    @headers = @champs.each_with_object([]) do |champ, acc|
      acc.push(champ) if champ.type_champ == 'header_section'
      acc
    end
  rescue ActiveRecord::RecordNotFound
    flash.alert = t('errors.messages.dossier_not_found')
    redirect_to root_path
  end

  # def error
  #   show
  #   flash.now.alert = 'Un ou plusieurs attributs obligatoires sont manquants ou incorrects.'
  #   render 'show'
  # end

  def create
    @dossier = current_user_dossier
    @procedure = @dossier.procedure
    @champs = @dossier.ordered_champs

    mandatory = true
    mandatory = params[:submit].keys.first != 'brouillon' unless params[:submit].nil?

    unless @dossier.update_attributes(create_params)
      @dossier = @dossier.decorate

      flash.alert = @dossier.errors.full_messages.join('<br />').html_safe
      return redirect_to users_dossier_description_path(dossier_id: @dossier.id)
    end

    unless params[:champs].nil?
      champs_service_errors = ChampsService.save_formulaire @dossier.champs, params, mandatory

      unless champs_service_errors.empty?
        flash.alert = champs_service_errors.map { |e| e[:message] }.join('<br>')
        return redirect_to users_dossier_description_path(dossier_id: @dossier.id)
      end
    end

    if @procedure.cerfa_flag?
      unless params[:cerfa_pdf].nil?
        cerfa = Cerfa.new(content: params[:cerfa_pdf], dossier: @dossier, user: current_user)
        unless cerfa.save
          flash.alert = cerfa.errors.full_messages.join('<br />').html_safe
          return redirect_to users_dossier_description_path(dossier_id: @dossier.id)
        end
      end
    end

    unless (errors_upload = PiecesJustificativesService.upload!(@dossier, current_user, params)).empty?
      flash.alert = errors_upload.html_safe
      return redirect_to users_dossier_description_path(dossier_id: @dossier.id)
    end

    if mandatory
      @dossier.initiated! if @dossier.draft?

      flash.notice = 'Votre simplification a été enregistrée.'
      redirect_to url_for(controller: :'backoffice/dossiers', action: :show, id: @dossier.id)
    else
      flash.notice = 'Votre brouillon a bien été sauvegardé.'
      redirect_to url_for(controller: :dossiers, action: :index, liste: :brouillon)
    end
  end

  def pieces_justificatives
    invite = current_user.invite? params[:dossier_id]

    @dossier ||= Dossier.find(params[:dossier_id]) if invite
    @dossier ||= current_user_dossier

    if @dossier.procedure.cerfa_flag?
      unless params[:cerfa_pdf].nil?
        cerfa = Cerfa.new(content: params[:cerfa_pdf], dossier: @dossier, user: current_user)
        unless cerfa.save
          flash.alert = cerfa.errors.full_messages.join('<br />').html_safe
        end
      end
    end

    if !(errors_upload = PiecesJustificativesService.upload!(@dossier, current_user, params)).empty?
      if flash.alert.nil?
        flash.alert = errors_upload.html_safe
      else
        flash.alert = (flash.alert + '<br />' + errors_upload.html_safe).html_safe
      end

    else
      flash.notice = 'Nouveaux fichiers envoyés' if flash.alert.nil?
      @dossier.next_step! 'user', 'update'
    end

    return redirect_to users_dossiers_invite_path(id: current_user.invites.find_by_dossier_id(@dossier.id).id) if invite

    redirect_to users_dossier_recapitulatif_path
  end

  def self.route_authorization
    {
      states: %i[draft initiated replied updated]
    }
  end

  private

  def check_starter_dossier_informations
    @dossier ||= current_user_dossier

    if (@dossier.procedure.for_individual? && @dossier.individual.nil?) ||
       (!@dossier.procedure.for_individual? && @dossier.entreprise.nil?)
      redirect_to url_for(users_dossier_path(@dossier.id))
    end
  end

  def create_params
    params.permit
  end
end
