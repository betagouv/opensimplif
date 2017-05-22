class FixDefaultTypeOnTypeDeChampTable < ActiveRecord::Migration
  class TypeDeChamp < ActiveRecord::Base
  end

  def up
    remove_column :types_de_champ, :private
  end

  def down
    add_column :types_de_champ, :private, :boolean, default: true
  end
end
