class AddDossierToUnread < ActiveRecord::Migration[5.0]
  def change
    add_reference :unreads, :dossier, references: :dossiers
  end
end
