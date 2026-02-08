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
  scope :tagged_with, ->(tag) {
    where("tags LIKE ?", "%#{sanitize_sql_like(tag)}%") if tag.present?
  }
  scope :search, ->(query) {
    return published.recent if query.blank?

    published.where(
      'title LIKE ? OR content LIKE ? OR excerpt LIKE ?',
      "%#{sanitize_sql_like(query)}%",
      "%#{sanitize_sql_like(query)}%",
      "%#{sanitize_sql_like(query)}%"
    ).recent
  }

  # Find by slug
  def to_param
    slug
  end

  # Tags getter - returns array from JSON text column
  def tags
    return [] if self[:tags].blank?
    JSON.parse(self[:tags])
  rescue JSON::ParserError
    []
  end

  # Tags setter - stores array as JSON in text column
  def tags=(value)
    value = value.split(',').map(&:strip) if value.is_a?(String)
    self[:tags] = value.to_a.compact.uniq.to_json
  end

  # Get all unique tags across all posts
  def self.all_tags
    published
      .where.not(tags: [nil, ''])
      .pluck(:tags)
      .map { |t| JSON.parse(t) rescue [] }
      .flatten
      .uniq
      .sort
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
