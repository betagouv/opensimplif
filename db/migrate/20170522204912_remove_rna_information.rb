class RemoveRNAInformation < ActiveRecord::Migration[5.0]
  def up
    replace_view :searches, version: 3
    drop_table :rna_informations
  end

  def down
    create_table :rna_informations do |t|
      t.string :association_id
      t.string :titre
      t.text :objet
      t.date :date_creation
      t.date :date_declaration
      t.date :date_publication
    end

    add_reference :rna_informations, :entreprise, references: :entreprise

    replace_view :searches, version: 2
  end
end
