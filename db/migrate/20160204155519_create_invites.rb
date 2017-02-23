class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
      t.string :email
      t.string :email_sender
    end

    add_reference :invites, :dossier, references: :dossiers
    add_reference :invites, :user, references: :users
  end
end
