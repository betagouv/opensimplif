class CreateTypesDeChamps < ActiveRecord::Migration
  def change
    create_table :types_de_champs do |t|
      t.string :libelle
      t.string :type
      t.integer :order_place

      t.belongs_to :procedure
    end
  end
end
