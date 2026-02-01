# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:likes).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:user, github_id: "abc123", github_login: "testuser") }

    it { is_expected.to validate_presence_of(:github_id) }
    it { is_expected.to validate_presence_of(:github_login) }
    it { is_expected.to validate_uniqueness_of(:github_id) }
    it { is_expected.to validate_uniqueness_of(:github_login) }
  end

  describe ".find_or_create_from_github" do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        uid: "12345",
        info: {
          nickname: "testuser",
          name: "Test User",
          image: "https://avatars.githubusercontent.com/u/12345"
        }
      )
    end

    context "when user does not exist" do
      it "creates a new user" do
        expect {
          User.find_or_create_from_github(auth_hash)
        }.to change(User, :count).by(1)
      end

      it "sets the correct attributes" do
        user = User.find_or_create_from_github(auth_hash)
        expect(user.github_id).to eq("12345")
        expect(user.github_login).to eq("testuser")
        expect(user.name).to eq("Test User")
        expect(user.avatar_url).to eq("https://avatars.githubusercontent.com/u/12345")
      end
    end

    context "when user already exists" do
      let!(:existing_user) { create(:user, github_id: "12345", github_login: "oldlogin") }

      it "does not create a new user" do
        expect {
          User.find_or_create_from_github(auth_hash)
        }.not_to change(User, :count)
      end

      it "updates the user attributes" do
        user = User.find_or_create_from_github(auth_hash)
        expect(user.id).to eq(existing_user.id)
        expect(user.github_login).to eq("testuser")
        expect(user.name).to eq("Test User")
      end
    end
  end

  describe "#admin?" do
    it "returns true for AnsibleMage" do
      user = build(:user, github_login: "AnsibleMage")
      expect(user.admin?).to be true
    end

    it "returns false for other users" do
      user = build(:user, github_login: "otheruser")
      expect(user.admin?).to be false
    end
  end

  describe "#display_name" do
    it "returns name when present" do
      user = build(:user, name: "Test User", github_login: "testuser")
      expect(user.display_name).to eq("Test User")
    end

    it "returns github_login when name is blank" do
      user = build(:user, name: nil, github_login: "testuser")
      expect(user.display_name).to eq("testuser")
    end

    it "returns github_login when name is empty string" do
      user = build(:user, name: "", github_login: "testuser")
      expect(user.display_name).to eq("testuser")
    end
  end
end
