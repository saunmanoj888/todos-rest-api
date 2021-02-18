FactoryBot.define do
  factory :item do
    todo
    assignee factory: :user
    name { Faker::Lorem.word }
    creator_id { todo.creator.id }
    assignee_id { assignee.id }
    checked { false }
  end
end
