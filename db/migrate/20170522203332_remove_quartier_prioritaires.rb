class RemoveQuartierPrioritaires < ActiveRecord::Migration[5.0]
  def up
    drop_table :quartier_prioritaires
  end

  def down
    create_table :quartier_prioritaires do |t|
      t.string :code
      t.string :nom
      t.string :commune
      t.text :geometry
    end

    add_reference :quartier_prioritaires, :dossier, references: :dossiers
  end
end
