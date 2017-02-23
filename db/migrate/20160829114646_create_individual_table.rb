class CreateIndividualTable < ActiveRecord::Migration
  def change
    create_table :individuals do |t|
      t.string :nom
      t.string :prenom
      t.string :birthdate
    end

    add_belongs_to :individuals, :dossier
  end
end
