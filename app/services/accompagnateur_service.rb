class AccompagnateurService
  ASSIGN = 'assign'.freeze
  NOT_ASSIGN = 'not_assign'.freeze

  def initialize(accompagnateur, procedure, to)
    @accompagnateur = accompagnateur
    @procedure = procedure
    @to = to
  end

  def change_assignement!
    if @to == ASSIGN
      AssignTo.create(gestionnaire: @accompagnateur, procedure: @procedure)
    elsif @to == NOT_ASSIGN
      AssignTo.where(gestionnaire: @accompagnateur, procedure: @procedure).delete_all
    end
  end

  def build_default_column
    return unless @to == ASSIGN
    return unless PreferenceListDossier.where(gestionnaire: @accompagnateur, procedure: @procedure).empty?

    @accompagnateur.build_default_preferences_list_dossier @procedure.id
  end
end
