class ChangeDatePrevisionnelDataType < ActiveRecord::Migration
  def change
    remove_column :dossiers, :date_previsionnelle
    add_column :dossiers, :date_previsionnelle, :date
  end
end
