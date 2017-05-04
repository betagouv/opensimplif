FactoryGirl.define do
  factory :commentaire do
    body 'plop'

    before(:create) do |commentaire, _evaluator|
      commentaire.dossier = create :dossier unless commentaire.dossier
    end
  end
end
