FactoryBot.define do
  factory :role do
    name { 'SuperAdmin' }
    level { 20 }
    permissions { |a| [a.association(:permission, :manage)] }

    trait :supervisor do
      name { 'Supervisor' }
      level { 15 }
    end

    trait :member do
      name { 'Member' }
      level { 5 }
      permissions { |a| [a.association(:permission, :read)] }
    end
  end
end
