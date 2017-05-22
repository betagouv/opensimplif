class AddTypeAttrInChampTable < ActiveRecord::Migration
  class TypeDeChamp < ActiveRecord::Base
    has_many :champs
  end

  class Champ < ActiveRecord::Base
    belongs_to :type_de_champ
  end

  def up
    add_column :champs, :type, :string
  end

  def down
    remove_column :champs, :type
  end
end
