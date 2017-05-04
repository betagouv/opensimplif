class Backoffice::Dossiers::ProcedureController < Backoffice::DossiersListController
  def index
    super

    dossiers_list_facade.service.filter_procedure! params[:id]

    redirect_to simplifications_path
  rescue ActiveRecord::RecordNotFound
    flash.alert = "Cette procédure n'existe pas ou vous n'y avez pas accès."
    redirect_to simplifications_path
  end

  def filter
    super

    redirect_to simplification_path(id: params[:id])
  end

  private

  def retrieve_procedure
    Procedure.find params[:id]
  end
end
