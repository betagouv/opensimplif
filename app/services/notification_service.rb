class NotificationService
  attr_reader :notification

  def initialize(type_notif, notification_text, dossier_id)
    liste = [notification_text]
    @notification = Notification.new dossier_id: dossier_id, type_notif: type_notif, liste: liste, already_read: true
  end

  def notify
    @notification.save
  end
end
