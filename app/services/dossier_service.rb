class DossierService
  def initialize(dossier, siret, france_connect_information)
    @dossier = dossier
    @siret = siret
    @france_connect_information = france_connect_information
  end

  def dossier_informations!
    @entreprise_adapter = SIADE::EntrepriseAdapter.new(DossierService.siren(@siret))

    raise RestClient::ResourceNotFound if @entreprise_adapter.to_params.nil?

    @etablissement_adapter = SIADE::EtablissementAdapter.new(@siret)

    raise RestClient::ResourceNotFound if @etablissement_adapter.to_params.nil?

    @dossier.create_entreprise(@entreprise_adapter.to_params)
    @dossier.create_etablissement(@etablissement_adapter.to_params)

    @dossier.update_attributes(mandataire_social: mandataire_social?(@entreprise_adapter.mandataires_sociaux))
    @dossier.etablissement.update_attributes(entreprise: @dossier.entreprise)

    @dossier
  end

  def self.siren(siret)
    siret[0..8]
  end

  private

  def mandataire_social?(mandataires_list)
    unless @france_connect_information.nil?

      mandataires_list.each do |mandataire|
        return true if mandataire[:nom].casecmp(@france_connect_information.family_name.upcase).zero? &&
                       mandataire[:prenom].casecmp(@france_connect_information.given_name.upcase).zero? &&
                       mandataire[:date_naissance_timestamp] == @france_connect_information.birthdate.to_time.to_i
      end
    end

    false
  end
end
