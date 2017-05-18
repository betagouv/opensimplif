class Etablissement < ActiveRecord::Base
  belongs_to :dossier
  belongs_to :entreprise

  has_many :exercices, dependent: :destroy

  validates_uniqueness_of :dossier_id

  def geo_adresse
    [numero_voie, type_voie, nom_voie, complement_adresse, code_postal, localite].join(' ')
  end
end
