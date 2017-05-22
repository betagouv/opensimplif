class AdminTypesDeChampFacades
  include Rails.application.routes.url_helpers

  def initialize(procedure)
    @procedure = procedure
  end

  def active
    'Champs'
  end

  def url
    admin_procedure_types_de_champ_path(@procedure)
  end

  def types_de_champ
    @procedure.types_de_champ_ordered.decorate
  end

  def new_type_de_champ
    TypeDeChampPublic.new.decorate
  end

  def fields_for_var
    :types_de_champ
  end

  def move_up_url(ff)
    move_up_admin_procedure_types_de_champ_path(@procedure, ff.index)
  end

  def move_down_url(ff)
    move_down_admin_procedure_types_de_champ_path(@procedure, ff.index)
  end

  def delete_url(ff)
    admin_procedure_type_de_champ_path(@procedure, ff.object.id)
  end

  def add_button_id
    :add_type_de_champ
  end
end
