class Commentaire < ActiveRecord::Base
  belongs_to :dossier
  belongs_to :champ
  belongs_to :piece_justificative

  # TODO: Make a validation to be sure one of those three elements is filled

  after_save :internal_notification

  def header
    date = created_at.localtime.strftime('%d %b %Y %H:%M')
    "#{email}, #{date}"
  end

  private

  def internal_notification
    if !piece_justificative && body.present?
      NotificationService.new('commentaire', notification_text, dossier.id).notify
    end
  end

  def notification_text
    if champ
      "Nouveau commentaire sur le champ #{champ.type_de_champ.libelle} par #{email}."
    else
      "Nouveau commentaire dans la messagerie par #{email}."
    end
  end
end
