class NotificationService
  attr_reader :notification, :type_notif, :dossier_id, :attribut_change

  def initialize(type_notif, dossier_id, attribut_change = '')
    @type_notif = type_notif
    @dossier_id = dossier_id
    @attribut_change = attribut_change

    liste = [notification_text]
    @notification = Notification.new dossier_id: dossier_id, type_notif: type_notif, liste: liste, already_read: true
  end

  def notify
    @notification.save
  end

  private

  def notification_text
    case @type_notif
    when 'commentaire'
      'Un nouveau commentaire sur le dossier.'
    when 'commentaire_champ'
      'Un nouveau commentaire sur un champ.'
    when 'commentaire_piece'
      'Un nouveau commentaire sur une pièce.'
    when 'cerfa'
      'Un nouveau formulaire a été déposé.'
    when 'piece_justificative'
      @attribut_change
    when 'champs'
      @attribut_change
    when 'submitted'
      "Le dossier n°#{@dossier_id} a été déposé."
    else
      ''
    end
  end
end
