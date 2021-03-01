FactoryBot.define do
  factory :user do
    username { Faker::Name.name }
    password { 'password' }
    role { 'Admin' }
    email { "#{Faker::Name.first_name}@example.com" }
    first_name { 'john' }
    last_name { 'Doe' }
  end
end
