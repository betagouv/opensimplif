class Admin::PrevisualisationsController < AdminController
  before_action :retrieve_procedure

  def show
    @dossier = Dossier.new(id: 0, procedure: @procedure)

    PrevisualisationService.destroy_all_champs @dossier
    @dossier.build_default_champs

    @champs = @dossier.ordered_champs

    @headers = @champs.each_with_object([]) do |champ, acc|
      acc.push(champ) if champ.type_champ == 'header_section'
      acc
    end
  end
end
