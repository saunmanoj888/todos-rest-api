FactoryBot.define do
  factory :todo do
    creator factory: :user
    title { Faker::Lorem.word }
    status { 'draft' }
    creator_id { creator.id }
  end
end
