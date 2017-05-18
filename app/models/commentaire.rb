class Commentaire < ActiveRecord::Base
  belongs_to :dossier
  belongs_to :champ
  belongs_to :piece_justificative

  after_save :internal_notification

  def header
    date = created_at.localtime.strftime('%d %b %Y %H:%M')
    "#{email}, #{date}"
  end

  private

  def internal_notification
    NotificationService.new('commentaire', notification_text, dossier.id).notify
  end

  def notification_text
    if champ
      "Un nouveau commentaire sur le champ #{champ.type_de_champ.libelle} > #{champ.value}."
    elsif piece_justificative
      "Un nouveau commentaire sur la pièce #{piece_justificative.content}."
    else
      'Un nouveau commentaire sur la simplification.'
    end
  end
end
