class RemoveTypeFromTypeDeChamp < ActiveRecord::Migration[5.0]
  def change
    remove_column :types_de_champ, :type, :string
    remove_column :champs, :type, :string
  end
end
