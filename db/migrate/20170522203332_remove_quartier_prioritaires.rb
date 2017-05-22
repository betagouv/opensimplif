class RemoveQuartierPrioritaires < ActiveRecord::Migration[5.0]
  def change
    drop_table :quartier_prioritaires
  end
end
