class RemoveAutorisationDonneesFromDossier < ActiveRecord::Migration[5.0]
  def change
    remove_column :dossiers, :autorisation_donnees, :boolean
    remove_column :individuals, :birthdate, :date
  end
end
