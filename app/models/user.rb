# frozen_string_literal: true

class User < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :nullify

  validates :github_id, presence: true, uniqueness: true
  validates :github_login, presence: true, uniqueness: true

  def self.find_or_create_from_github(auth)
    user = find_or_initialize_by(github_id: auth.uid)
    user.update!(
      github_login: auth.info.nickname,
      name: auth.info.name,
      avatar_url: auth.info.image
    )
    user
  end

  def admin?
    github_login == "AnsibleMage"
  end

  def display_name
    name.presence || github_login
  end
end
