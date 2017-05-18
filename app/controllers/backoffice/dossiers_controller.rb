class Backoffice::DossiersController < Backoffice::DossiersListController
  respond_to :html, :xlsx, :ods, :csv

  def index
    procedure = current_gestionnaire.procedure_filter

    if procedure.nil?
      procedure_list = dossiers_list_facade.gestionnaire_procedures_name_and_id_list
      if procedure_list.count.zero?
        flash.alert = "Vous n'avez aucune procédure d'affectée."
        return redirect_to root_path
      end

      procedure = procedure_list.first[:id]
    end

    redirect_to backoffice_dossiers_procedure_path(id: procedure)
  end

  def show
    create_dossier_facade params[:id]

    Unread.where(gestionnaire: current_gestionnaire, dossier: params[:id]).delete_all

    unless @facade.nil?
      @champs_private = @facade.champs_private

      @headers_private = @champs_private.each_with_object([]) do |champ, acc|
        acc.push(champ) if champ.type_champ == 'header_section'
        acc
      end
    end
  end

  def filter
    super

    redirect_to backoffice_dossiers_path(liste: param_liste)
  end

  def download_dossiers_tps
    dossiers = dossiers_list_facade(param_liste).dossiers_to_display
    if Procedure.find_by(id: params[:procedure_id])
      respond_with Dossier.export_full_generation(dossiers, request.format) unless dossiers.empty?
    else
      respond_to do |format|
        format.xlsx { render xlsx: dossiers }
        format.ods { render ods: dossiers }
        format.csv { render csv: dossiers }
      end
    end
  end

  def search
    @search_terms = params[:q]

    # exact id match?
    @dossiers = Dossier.where(id: @search_terms.to_i) if @search_terms.to_i < 2_147_483_647
    @dossiers = Dossier.none if @dossiers.nil?

    # full text search
    unless @dossiers.any?
      @dossiers = Search.new(
        gestionnaire: current_gestionnaire,
        query: @search_terms,
        page: params[:page]
      ).results
    end

    smart_listing_create :search,
                         @dossiers,
                         partial: 'backoffice/dossiers/list',
                         array: true,
                         default_sort: dossiers_list_facade.service.default_sort
  rescue RuntimeError
    smart_listing_create :search,
                         [],
                         partial: 'backoffice/dossiers/list',
                         array: true,
                         default_sort: dossiers_list_facade.service.default_sort
  end

  def valid
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'valid'
    flash.notice = 'Dossier confirmé avec succès.'

    # #NotificationMailer.dossier_validated(@facade.dossier).deliver_now!

    redirect_to backoffice_dossier_path(id: @facade.dossier.id)
  end

  def receive
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'receive'
    flash.notice = 'Dossier considéré comme reçu.'

    # NotificationMailer.dossier_received(@facade.dossier).deliver_now!

    redirect_to backoffice_dossier_path(id: @facade.dossier.id)
  end

  def refuse
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'refuse'
    flash.notice = 'Dossier considéré comme refusé.'

    # NotificationMailer.dossier_refused(@facade.dossier).deliver_now!

    redirect_to backoffice_dossier_path(id: @facade.dossier.id)
  end

  def without_continuation
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'without_continuation'
    flash.notice = 'Dossier considéré comme sans suite.'

    # NotificationMailer.dossier_without_continuation(@facade.dossier).deliver_now!

    redirect_to backoffice_dossier_path(id: @facade.dossier.id)
  end

  def close
    create_dossier_facade params[:dossier_id]

    @facade.dossier.next_step! 'gestionnaire', 'close'
    flash.notice = 'Dossier traité avec succès.'

    # NotificationMailer.dossier_closed(@facade.dossier).deliver_now!

    redirect_to backoffice_dossier_path(id: @facade.dossier.id)
  end

  def follow
    follow = current_gestionnaire.toggle_follow_dossier params[:dossier_id]

    Dossier.find(params[:dossier_id]).next_step! 'gestionnaire', 'follow'

    flash.notice = 'Simplification suivie' if follow.class == Follow
    redirect_to request.referer
  end

  def reload_smartlisting
    begin
      @liste = URI(request.referer).query.split('=').second
    rescue NoMethodError
      @liste = cookies[:liste] || 'all_state'
    end

    smartlisting_dossier

    render 'backoffice/dossiers/index', formats: :js
  end

  def archive
    facade = create_dossier_facade params[:dossier_id]
    unless facade.dossier.archived
      facade.dossier.update(archived: true)
      flash.notice = 'Dossier archivé'
    end
    redirect_to backoffice_dossiers_path
  end

  private

  def create_dossier_facade(dossier_id)
    @facade = DossierFacades.new dossier_id, current_gestionnaire.email
  rescue ActiveRecord::RecordNotFound
    flash.alert = t('errors.messages.dossier_not_found')
    redirect_to url_for(controller: '/backoffice')
  end

  def retrieve_procedure
    return if params[:procedure_id].blank?
    current_gestionnaire.procedures.find params[:procedure_id]
  end
end
