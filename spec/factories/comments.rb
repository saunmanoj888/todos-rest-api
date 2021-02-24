FactoryBot.define do
  factory :comment do
    item
    body { 'test comment' }
    status { 'rejected' }
  end
end
