class Etablissement < ActiveRecord::Base
  belongs_to :dossier
  belongs_to :entreprise

  validates_uniqueness_of :dossier_id

  def geo_adresse
    [numero_voie, type_voie, nom_voie, complement_adresse, code_postal, localite].join(' ')
  end
end
