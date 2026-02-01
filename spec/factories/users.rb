# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:github_id) { |n| "#{n}12345" }
    sequence(:github_login) { |n| "testuser#{n}" }
    name { "Test User" }
    avatar_url { "https://avatars.githubusercontent.com/u/12345" }
  end
end
