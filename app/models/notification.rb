class Notification < ActiveRecord::Base
  belongs_to :dossier
  delegate :procedure, to: :dossier

  has_many :unreads

  after_save :deliver_unread

  enum type_notif: {commentaire: 'commentaire', cerfa: 'cerfa', piece_justificative: 'piece_justificative', champs: 'champs', submitted: 'submitted'}

  def deliver_unread
    dossier.follows.each do |follow|
      Unread.create gestionnaire: follow.gestionnaire, notification: self, dossier_id: dossier.id
    end

    gestionnaire = Gestionnaire.find_by_email(dossier.user.email)
    Unread.create gestionnaire: gestionnaire, notification: self, dossier_id: dossier.id
  end
end
