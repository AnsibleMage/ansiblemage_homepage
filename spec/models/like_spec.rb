# frozen_string_literal: true

require "rails_helper"

RSpec.describe Like, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:post).counter_cache(true) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:ip_address) }

    describe "uniqueness" do
      context "when user is present" do
        let(:user) { create(:user) }
        let(:post) { create(:post) }
        let!(:existing_like) { create(:like, post: post, user: user, ip_address: "127.0.0.1") }

        it "prevents duplicate likes from same user on same post" do
          duplicate = build(:like, post: post, user: user, ip_address: "192.168.1.1")
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:user_id]).to include("has already been taken")
        end

        it "allows same user to like different posts" do
          other_post = create(:post, title: "Other Post")
          new_like = build(:like, post: other_post, user: user, ip_address: "127.0.0.1")
          expect(new_like).to be_valid
        end
      end

      context "when user is nil (anonymous)" do
        let(:post) { create(:post) }
        let!(:existing_like) { create(:like, post: post, user: nil, ip_address: "127.0.0.1") }

        it "prevents duplicate likes from same IP on same post" do
          duplicate = build(:like, post: post, user: nil, ip_address: "127.0.0.1")
          expect(duplicate).not_to be_valid
          expect(duplicate.errors[:ip_address]).to include("has already been taken")
        end

        it "allows same IP to like different posts" do
          other_post = create(:post, title: "Other Post")
          new_like = build(:like, post: other_post, user: nil, ip_address: "127.0.0.1")
          expect(new_like).to be_valid
        end

        it "allows different IPs to like same post" do
          new_like = build(:like, post: post, user: nil, ip_address: "192.168.1.1")
          expect(new_like).to be_valid
        end
      end
    end
  end

  describe "counter cache" do
    let(:post) { create(:post) }

    it "increments likes_count when like is created" do
      expect {
        create(:like, post: post, ip_address: "127.0.0.1")
      }.to change { post.reload.likes_count }.by(1)
    end

    it "decrements likes_count when like is destroyed" do
      like = create(:like, post: post, ip_address: "127.0.0.1")
      expect {
        like.destroy
      }.to change { post.reload.likes_count }.by(-1)
    end
  end

  describe ".by_ip" do
    let(:post) { create(:post) }
    let!(:like1) { create(:like, post: post, ip_address: "127.0.0.1") }
    let!(:like2) { create(:like, post: post, ip_address: "192.168.1.1") }

    it "finds likes by IP address" do
      expect(Like.by_ip("127.0.0.1")).to include(like1)
      expect(Like.by_ip("127.0.0.1")).not_to include(like2)
    end
  end
end
