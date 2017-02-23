class Gestionnaire < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_and_belongs_to_many :administrateurs

  has_one :preference_smart_listing_page, dependent: :destroy

  has_many :assign_to, dependent: :destroy
  has_many :procedures, -> { where('published = ?', true) }, through: :assign_to
  has_many :dossiers, -> { where.not(state: :draft) }, through: :procedures
  has_many :follows
  has_many :preference_list_dossiers
  has_many :unreads

  after_create :build_default_preferences_list_dossier
  after_create :build_default_preferences_smart_listing_page

  include CredentialsSyncableConcern

  def dossiers_follow
    @dossiers_follow ||= dossiers.joins(:follows).where("follows.gestionnaire_id = #{id}")
  end

  def procedure_filter
    return nil unless assign_to.pluck(:procedure_id).include?(self[:procedure_filter])

    self[:procedure_filter]
  end

  def toggle_follow_dossier dossier_id
    dossier = dossier_id
    dossier = Dossier.find(dossier_id) unless dossier_id.class == Dossier

    Follow.create!(dossier: dossier, gestionnaire: self)
  rescue ActiveRecord::RecordInvalid
    Follow.where(dossier: dossier, gestionnaire: self).delete_all
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def follow? dossier_id
    dossier_id = dossier_id.id if dossier_id.class == Dossier

    Follow.where(gestionnaire_id: id, dossier_id: dossier_id).any?
  end

  def build_default_preferences_list_dossier procedure_id=nil

    PreferenceListDossier.available_columns_for(procedure_id).each do |table|
      table.second.each do |column|

        if valid_couple_table_attr? table.first, column.first
          PreferenceListDossier.create(
              libelle: column.second[:libelle],
              table: column.second[:table],
              attr: column.second[:attr],
              attr_decorate: column.second[:attr_decorate],
              bootstrap_lg: column.second[:bootstrap_lg],
              order: nil,
              filter: nil,
              procedure_id: procedure_id,
              gestionnaire: self
          )
        end
      end
    end
  end

  def build_default_preferences_smart_listing_page
    PreferenceSmartListingPage.create(page: 1, procedure: nil, gestionnaire: self, liste: 'all_state')
  end

  def notifications
    Notification.where(already_read: false, dossier_id: follows.pluck(:dossier_id)).order("updated_at DESC")
  end

  def notifications_for procedure
    procedure_ids = dossiers_follow.pluck(:procedure_id)

    if procedure_ids.include?(procedure.id)
      return dossiers_follow.where(procedure_id: procedure.id)
                 .inject(0) do |acc, dossier|
        acc += dossier.notifications.where(already_read: false).count
      end
    end
    0
  end

  def dossier_with_notification_for procedure
    procedure_ids = dossiers_follow.pluck(:procedure_id)

    if procedure_ids.include?(procedure.id)
      return dossiers_follow.where(procedure_id: procedure.id)
                 .inject(0) do |acc, dossier|
        acc += ((dossier.notifications.where(already_read: false).count) > 0 ? 1 : 0)
      end
    end
    0
  end

  private

  def valid_couple_table_attr? table, column
    couples = [{
                   table: :dossier,
                   column: :dossier_id
               }, {
                   table: :user,
                   column: :email
               }, {
                   table: :dossier,
                   column: :created_at
               }, {
                   table: :dossier,
                   column: :updated_at
               }]

    couples.include?({table: table, column: column})
  end
end
