class Dossier < ActiveRecord::Base
  include SpreadsheetArchitect

  enum state: {draft: 'draft',
               initiated: 'initiated',
               replied: 'replied', # action utilisateur demandé
               updated: 'updated', # etude par l'administration en cours
               validated: 'validated',
               submitted: 'submitted',
               received: 'received',
               closed: 'closed',
               refused: 'refused',
               without_continuation: 'without_continuation'}

  has_one :etablissement, dependent: :destroy
  has_one :entreprise, dependent: :destroy
  has_one :individual, dependent: :destroy
  has_many :cerfa, dependent: :destroy

  has_many :pieces_justificatives, dependent: :destroy
  has_many :champs, class_name: 'ChampPublic', dependent: :destroy
  has_many :champs_private, class_name: 'ChampPrivate', dependent: :destroy
  has_many :quartier_prioritaires, dependent: :destroy
  has_many :cadastres, dependent: :destroy
  has_many :commentaires, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :invites_user, class_name: 'InviteUser', dependent: :destroy
  has_many :follows
  has_many :notifications, dependent: :destroy
  has_many :unreads, dependent: :destroy

  belongs_to :procedure
  belongs_to :user

  accepts_nested_attributes_for :individual

  delegate :siren, to: :entreprise
  delegate :siret, to: :etablissement, allow_nil: true
  delegate :types_de_piece_justificative, to: :procedure
  delegate :types_de_champ, to: :procedure
  delegate :france_connect_information, to: :user

  after_save :build_default_champs, if: proc { procedure_id_changed? }
  after_save :build_default_individual, if: proc { procedure.for_individual? }
  after_save :internal_notification

  validates :user, presence: true

  BROUILLON = %w[draft].freeze
  NOUVEAUX = %w[initiated].freeze
  OUVERT = %w[updated replied].freeze
  WAITING_FOR_GESTIONNAIRE = %w[updated].freeze
  WAITING_FOR_USER = %w[replied validated].freeze
  EN_CONSTRUCTION = %w[initiated updated replied].freeze
  VALIDES = %w[validated].freeze
  DEPOSES = %w[submitted].freeze
  EN_INSTRUCTION = %w[submitted received].freeze
  A_INSTRUIRE = %w[received].freeze
  TERMINE = %w[closed refused without_continuation].freeze
  ALL_STATE = %w[initiated updated replied validated submitted received closed refused without_continuation].freeze

  def unreaded_notifications
    @unreaded_notif ||= notifications.where(already_read: false)
  end

  def first_unread_notification
    unreaded_notifications.order('created_at ASC').first
  end

  def retrieve_last_piece_justificative_by_type(type)
    pieces_justificatives.where(type_de_piece_justificative_id: type).last
  end

  def retrieve_all_piece_justificative_by_type(type)
    pieces_justificatives.where(type_de_piece_justificative_id: type).order(created_at: :DESC)
  end

  def build_default_champs
    procedure.types_de_champ.each do |type_de_champ|
      ChampPublic.create(type_de_champ_id: type_de_champ.id, dossier_id: id)
    end

    procedure.types_de_champ_private.each do |type_de_champ|
      ChampPrivate.create(type_de_champ_id: type_de_champ.id, dossier_id: id)
    end
  end

  def build_default_individual
    if Individual.where(dossier_id: id).count.zero?
      Individual.create(dossier: self)
    end
  end

  def ordered_champs
    champs.joins(', types_de_champ').where("champs.type_de_champ_id = types_de_champ.id AND types_de_champ.procedure_id = #{procedure.id}").order('order_place')
  end

  def ordered_champs_private
    champs_private.joins(', types_de_champ').where("champs.type_de_champ_id = types_de_champ.id AND types_de_champ.procedure_id = #{procedure.id}").order('order_place')
  end

  def ordered_pieces_justificatives
    champs.joins(', types_de_piece_justificative').where("pieces_justificatives.type_de_piece_justificative_id = types_de_piece_justificative.id AND types_de_piece_justificative.procedure_id = #{procedure.id}").order('order_place ASC')
  end

  def ordered_commentaires
    commentaires.order(created_at: :desc)
  end

  def next_step!(role, action)
    unless %w[initiate follow update comment valid submit receive refuse without_continuation close].include?(action)
      raise 'action is not valid'
    end

    raise 'role is not valid' unless %w[user gestionnaire].include?(role)

    if role == 'user'
      case action
      when 'initiate'
        initiated! if draft?
      when 'submit'
        submitted! if validated?
      when 'update'
        updated! if replied?
      when 'comment'
        updated! if replied?
      end
    elsif role == 'gestionnaire'
      case action
      when 'comment'
        if updated?
          replied!
        elsif initiated?
          replied!
        end
      when 'follow'
        updated! if initiated?
      when 'valid'
        if updated?
          validated!
        elsif replied?
          validated!
        elsif initiated?
          validated!
        end
      when 'receive'
        received! if submitted?
      when 'close'
        closed! if received?
      when 'refuse'
        refused! if received?
      when 'without_continuation'
        without_continuation! if received?
      end
    end
    state
  end

  def brouillon?
    BROUILLON.include?(state)
  end

  def self.all_state(order = 'ASC')
    where(state: ALL_STATE, archived: false).order("updated_at #{order}")
  end

  def self.brouillon(order = 'ASC')
    where(state: BROUILLON, archived: false).order("updated_at #{order}")
  end

  def self.nouveaux(order = 'ASC')
    where(state: NOUVEAUX, archived: false).order("updated_at #{order}")
  end

  def self.waiting_for_gestionnaire(order = 'ASC')
    where(state: WAITING_FOR_GESTIONNAIRE, archived: false).order("updated_at #{order}")
  end

  def self.waiting_for_user(order = 'ASC')
    where(state: WAITING_FOR_USER, archived: false).order("updated_at #{order}")
  end

  def self.en_construction(order = 'ASC')
    where(state: EN_CONSTRUCTION, archived: false).order("updated_at #{order}")
  end

  def self.ouvert(order = 'ASC')
    where(state: OUVERT, archived: false).order("updated_at #{order}")
  end

  def self.valides(order = 'ASC')
    where(state: VALIDES, archived: false).order("updated_at #{order}")
  end

  def self.fige(order = 'ASC')
    where(state: VALIDES, archived: false).order("updated_at #{order}")
  end

  def self.deposes(order = 'ASC')
    where(state: DEPOSES, archived: false).order("updated_at #{order}")
  end

  def self.a_instruire(order = 'ASC')
    where(state: A_INSTRUIRE, archived: false).order("updated_at #{order}")
  end

  def self.en_instruction(order = 'ASC')
    where(state: EN_INSTRUCTION, archived: false).order("updated_at #{order}")
  end

  def self.termine(order = 'ASC')
    where(state: TERMINE, archived: false).order("updated_at #{order}")
  end

  def cerfa_available?
    procedure.cerfa_flag? && !cerfa.empty?
  end

  def convert_specific_hash_values_to_string(hash_to_convert)
    hash = {}
    hash_to_convert.each do |key, value|
      value = value.to_s if !value.is_a?(Time) && !value.nil?
      hash.store(key, value)
    end
    hash
  end

  def convert_specific_array_values_to_string(array_to_convert)
    array = []
    array_to_convert.each do |value|
      value = value.to_s if !value.is_a?(Time) && !value.nil?
      array << value
    end
    array
  end

  def export_entreprise_data
    if entreprise.nil?
      etablissement_attr = EtablissementSerializer.new(Etablissement.new).attributes.map { |k, v| ["etablissement.#{k}".parameterize.underscore.to_sym, v] }.to_h
      entreprise_attr = EntrepriseSerializer.new(Entreprise.new).attributes.map { |k, v| ["entreprise.#{k}".parameterize.underscore.to_sym, v] }.to_h
    else
      etablissement_attr = EtablissementCsvSerializer.new(etablissement).attributes.map { |k, v| ["etablissement.#{k}".parameterize.underscore.to_sym, v] }.to_h
      entreprise_attr = EntrepriseSerializer.new(entreprise).attributes.map { |k, v| ["entreprise.#{k}".parameterize.underscore.to_sym, v] }.to_h
    end
    convert_specific_hash_values_to_string(etablissement_attr.merge(entreprise_attr))
  end

  def export_default_columns
    dossier_attr = DossierSerializer.new(self).attributes
    dossier_attr = convert_specific_hash_values_to_string(dossier_attr)
    dossier_attr = dossier_attr.merge(export_entreprise_data)
    dossier_attr
  end

  def spreadsheet_columns
    export_default_columns.to_a
  end

  def data_with_champs
    serialized_dossier = DossierProcedureSerializer.new(self)
    data = serialized_dossier.attributes.values
    data += champs.order('type_de_champ_id ASC').map(&:value)
    data += export_entreprise_data.values
    data
  end

  def export_headers
    serialized_dossier = DossierProcedureSerializer.new(self)
    headers = serialized_dossier.attributes.keys
    headers += procedure.types_de_champ.order('id ASC').map { |types_de_champ| types_de_champ.libelle.parameterize.underscore.to_sym }
    headers += export_entreprise_data.keys
    headers
  end

  def self.export_full_generation(dossiers, format)
    if dossiers && !dossiers.empty?
      data = []
      headers = dossiers.first.export_headers
      dossiers.each do |dossier|
        data << dossier.convert_specific_array_values_to_string(dossier.data_with_champs)
      end
      if ['csv'].include?(format)
        return SpreadsheetArchitect.to_csv(data: data, headers: headers)
      elsif ['xlsx'].include?(format)
        return SpreadsheetArchitect.to_xlsx(data: data, headers: headers)
      elsif ['ods'].include?(format)
        return SpreadsheetArchitect.to_ods(data: data, headers: headers)
      end
    end
  end

  def followers_gestionnaires_emails
    follows.includes(:gestionnaire).map(&:gestionnaire).pluck(:email).join(' ')
  end

  def reset!
    etablissement.destroy
    entreprise.destroy

    update_attributes(autorisation_donnees: false)
  end

  def total_follow
    follows.size
  end

  def submit!
    self.deposit_datetime = DateTime.now

    next_step! 'user', 'submit'
    # NotificationMailer.dossier_submitted(self).deliver_now!
  end

  def read_only?
    validated? || received? || submitted? || closed? || refused? || without_continuation?
  end

  def owner?(email)
    user.email == email
  end

  def invite_by_user?(email)
    (invites_user.pluck :email).include? email
  end

  private

  def internal_notification
    if state_changed? && state == 'submitted'
      NotificationService.new('submitted', "Le dossier n°#{id} a été déposé.", id).notify
    end
  end
end
