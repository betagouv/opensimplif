class DossierProcedureSerializer < ActiveModel::Serializer
  attributes :id,
             :created_at,
             :updated_at

  attribute :followers_gestionnaires_emails, key: :emails_accompagnateurs
end
