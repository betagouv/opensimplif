FactoryGirl.define do
  factory :preference_list_dossier do
    libelle 'Procedure'
    table 'procedure'
    add_attribute(:attr) { 'libelle' } # Use of add_attribute to prevent confusion with attr / attr_reader
    attr_decorate 'libelle'
    order nil
    filter nil
    bootstrap_lg 1
  end
end
