FactoryBot.define do
  factory :role do
    name { 'SuperAdmin' }
    level { 20 }
    permissions { |a| [a.association(:permission)] }
  end
end
