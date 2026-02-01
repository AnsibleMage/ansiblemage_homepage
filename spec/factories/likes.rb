# frozen_string_literal: true

FactoryBot.define do
  factory :like do
    association :post
    user { nil }
    sequence(:ip_address) { |n| "192.168.1.#{n}" }
  end
end
