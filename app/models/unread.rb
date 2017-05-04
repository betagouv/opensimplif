class Unread < ActiveRecord::Base
  belongs_to :notification
  belongs_to :gestionnaire
  belongs_to :dossier

  delegate :procedure, to: :notification

  validates :gestionnaire, presence: true
  validates :notification, presence: true

  validates_uniqueness_of :gestionnaire_id, scope: :notification_id
end
