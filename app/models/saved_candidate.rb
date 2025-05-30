class SavedCandidate < ApplicationRecord
  belongs_to :user
  belongs_to :resume
end
