# frozen_string_literal: true

FactoryBot.define do
  factory :comment do
    association :post
    association :user
    content { "This is a test comment." }
  end
end
