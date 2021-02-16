FactoryBot.define do
  factory :todo do
    user
    title { Faker::Lorem.word }
    status { 'created' }
    created_by { user.username }
  end
end
