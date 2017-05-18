class Notification < ActiveRecord::Base
  belongs_to :dossier
  delegate :procedure, to: :dossier

  has_many :unreads

  after_save :deliver_unread

  enum type_notif: {commentaire: 'commentaire', commentaire_champ: 'commentaire_champ', commentaire_piece: 'commentaire_piece', cerfa: 'cerfa', piece_justificative: 'piece_justificative', champs: 'champs', submitted: 'submitted'}

  def deliver_unread
    self.dossier.follows.each do |follow|
      Unread.create gestionnaire: follow.gestionnaire, notification: self, dossier_id: self.dossier.id
    end

    Unread.create gestionnaire: Gestionnaire.find_by_email(self.dossier.user.email), notification: self, dossier_id: self.dossier.id
  end
end
