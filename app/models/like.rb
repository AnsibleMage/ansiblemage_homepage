# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user, optional: true

  validates :ip_address, presence: true
  validates :user_id, uniqueness: { scope: :post_id }, if: -> { user_id.present? }
  validates :ip_address, uniqueness: { scope: :post_id }, if: -> { user_id.nil? }

  scope :by_ip, ->(ip) { where(ip_address: ip) }
end
