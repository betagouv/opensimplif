class RemoveGenderFromIndividual < ActiveRecord::Migration[5.0]
  def change
    remove_column :individuals, :gender, :string
  end
end
