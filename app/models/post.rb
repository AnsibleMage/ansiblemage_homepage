class Post < ApplicationRecord
  # Associations
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :content, presence: true
  validates :slug, presence: true, uniqueness: true

  # Callbacks
  before_validation :generate_slug, if: -> { slug.blank? }
  before_validation :generate_excerpt, if: -> { excerpt.blank? && content.present? }

  # Scopes
  scope :published, -> { where(published: true) }
  scope :drafts, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }

  # Find by slug
  def to_param
    slug
  end

  private

  def generate_slug
    base_slug = title.to_s.parameterize
    base_slug = SecureRandom.hex(4) if base_slug.blank?

    self.slug = base_slug
    counter = 1

    while Post.exists?(slug: slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def generate_excerpt
    self.excerpt = content.to_s.truncate(200, separator: ' ')
  end
end
