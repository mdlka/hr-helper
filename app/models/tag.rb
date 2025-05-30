class Tag < ApplicationRecord
  has_many :resume_tags
  has_many :resumes, through: :resume_tags
end
