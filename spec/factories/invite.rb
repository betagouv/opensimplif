FactoryGirl.define do
  factory :invite do
    email 'plop@octo.com'

    after(:build) do |invite, _evaluator|
      if invite.dossier.nil?
        invite.dossier = create(:dossier)
      end

      unless invite.user.nil?
        invite.email = invite.user.email
      end
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
