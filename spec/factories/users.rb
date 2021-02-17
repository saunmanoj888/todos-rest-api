FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    password { 'password' }
    type { 'Admin' }
  end
end
