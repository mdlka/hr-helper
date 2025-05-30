class Resume < ApplicationRecord
  belongs_to :user

  has_many :saved_candidates, dependent: :destroy
  has_many :resume_tags, dependent: :destroy
  has_many :tags, through: :resume_tags

  validates :content, presence: true
end
