FactoryGirl.define do
  factory :notification do
    type_notif 'commentaire'
    liste []

    before(:create) do |notification, _evaluator|
      notification.dossier = create :dossier unless notification.dossier
    end
  end
end
