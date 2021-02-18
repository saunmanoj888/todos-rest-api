FactoryBot.define do
  factory :item do
    creator factory: :user
    assignee factory: :user
    todo
    name { Faker::Lorem.word }
    creator_id { creator.id }
    assignee_id { assignee.id }
    checked { false }
  end
end
