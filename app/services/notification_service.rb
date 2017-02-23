class NotificationService

  def initialize type_notif, dossier_id, attribut_change=''
    @type_notif = type_notif
    @dossier_id = dossier_id

    notification.liste.push text_for_notif attribut_change
    notification.liste = notification.liste.uniq

    self
  end

  def notify
    notification.save
  end

  def notification
    @notification ||= Notification.new dossier_id: @dossier_id, type_notif: @type_notif, liste: [], already_read: true
  end

  def text_for_notif attribut=''
    case @type_notif
      when 'commentaire'
        "#{notification.liste.size + 1} nouveau(x) commentaire(s) déposé(s)."
      when 'cerfa'
        "Un nouveau formulaire a été déposé."
      when 'piece_justificative'
        attribut
      when 'champs'
        attribut
      when 'submitted'
        "Le dossier n°#{@dossier_id} a été déposé."
      else
        'Notification par défaut'
    end
  end
end
