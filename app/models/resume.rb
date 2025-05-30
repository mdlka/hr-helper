class Resume < ApplicationRecord
  belongs_to :user
  has_many :saved_candidates, dependent: :destroy
  has_many :resume_tags, dependent: :destroy
  has_many :tags, through: :resume_tags

  validates :content, presence: true
  validate :validate_content_length

  MIN_CONTENT_LENGTH = 100

  def parsed_summary
    JSON.parse(summary) rescue {}
  end

  private

  def validate_content_length
    if content.to_s.length < MIN_CONTENT_LENGTH
      errors.add(:content, "слишком короткий текст. Минимальная длина: #{MIN_CONTENT_LENGTH} символов")
    end
  end
end
