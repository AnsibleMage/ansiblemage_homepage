# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:content) }
    it { is_expected.to validate_length_of(:content).is_at_most(1000) }
  end

  describe "scopes" do
    describe ".recent" do
      let!(:old_comment) { create(:comment, created_at: 2.days.ago) }
      let!(:new_comment) { create(:comment, created_at: 1.day.ago) }

      it "returns comments in descending order" do
        expect(Comment.recent.first).to eq(new_comment)
        expect(Comment.recent.last).to eq(old_comment)
      end
    end
  end

  describe "defaults" do
    it "creates a valid comment with factory" do
      comment = build(:comment)
      expect(comment).to be_valid
    end
  end
end
