FactoryBot.define do
  factory :permission do
    trait :manage do
      name { 'can_manage_users' }
    end

    trait :read do
      name { 'can_read_users' }
    end
  end
end
