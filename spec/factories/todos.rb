FactoryBot.define do
  factory :todo do
    creator factory: :user
    title { Faker::Lorem.word }
    status { 'created' }
    creator_id { creator.id }
  end
end
