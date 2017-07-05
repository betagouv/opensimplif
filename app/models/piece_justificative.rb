class PieceJustificative < ActiveRecord::Base
  belongs_to :dossier
  belongs_to :type_de_piece_justificative
  has_one :commentaire

  belongs_to :user

  delegate :api_entreprise, :libelle, :order_place, to: :type_de_piece_justificative

  alias_attribute :type, :type_de_piece_justificative_id

  attr_accessor :commentaire_champ_libelle

  mount_uploader :content, PieceJustificativeUploader
  validates :content, file_size: {maximum: 20.megabytes}
  validates :content, presence: true, allow_blank: false, allow_nil: false

  after_save :internal_notification, if: proc { dossier.present? }

  def empty?
    content.blank?
  end

  def libelle
    if type_de_piece_justificative.nil?
      content.to_s
    else
      type_de_piece_justificative.libelle
    end
  end

  def content_url
    unless content.url.nil?
      if Features.remote_storage
        (RemoteDownloader.new content.filename).url
      else
        (LocalDownloader.new content.path,
                             (type_de_piece_justificative.nil? ? content.original_filename : type_de_piece_justificative.libelle)).url
      end
    end
  end

  def self.accept_format
    ' application/pdf,
      application/msword,
      application/vnd.openxmlformats-officedocument.wordprocessingml.document,
      application/vnd.ms-excel,
      application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,
      application/vnd.ms-powerpoint,
      application/vnd.openxmlformats-officedocument.presentationml.presentation,
      application/vnd.oasis.opendocument.text,
      application/vnd.oasis.opendocument.presentation,
      application/vnd.oasis.opendocument.spreadsheet,
      image/png,
      image/jpeg
    '
  end

  private

  def internal_notification
    if !type_de_piece_justificative.nil? || dossier.state != 'draft'
      NotificationService.new('piece_justificative', notification_text, dossier.id).notify
    end
  end

  def notification_text
    filename = original_filename.to_s.first(50)
    if commentaire_champ_libelle
      "Le fichier #{filename} a été joint au champ #{commentaire_champ_libelle} par #{user.email}."
    else
      "Le fichier #{filename} a été partagé dans la messagerie par #{user.email}."
    end
  end
end
