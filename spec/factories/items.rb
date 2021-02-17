FactoryBot.define do
  factory :item do
    user
    todo
    name { Faker::Lorem.word }
    added_by { user.username }
    checked { false }
  end
end
