# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Test Post #{n}" }
    content { "This is the content of the test post." }
    published { false }
  end
end
