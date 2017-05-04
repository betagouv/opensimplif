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
    NotificationService.new(kind, dossier.id).notify
  end

  def kind
    if champ
      'commentaire_champ'
    elsif piece_justificative
      'commentaire_piece'
    else
      'commentaire'
    end
  end
end
