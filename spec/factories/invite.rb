FactoryGirl.define do
  factory :invite do
    email 'plop@octo.com'

    after(:build) do |invite, _evaluator|
      invite.dossier = create(:dossier) if invite.dossier.nil?

      invite.email = invite.user.email unless invite.user.nil?
    end

    trait :with_user do
      after(:build) do |invite, _evaluator|
        if invite.user.nil?
          invite.user = create(:user)
          invite.email = invite.user.email
        end
      end
    end
  end
end
