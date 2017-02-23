class AddUnread < ActiveRecord::Migration[5.0]
  def change
    create_table :unreads do |t|
    end

    add_reference :unreads, :gestionnaire, references: :gestionnaires
    add_reference :unreads, :notification, references: :notifications
  end
end
