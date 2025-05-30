class SavedCandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saved_candidate, only: [:destroy]

  def index
    @saved_candidates = current_user.saved_candidates.includes(resume: :tags)
    @tags = Tag.all.order(:name)
    
    if params[:tag_ids].present?
      tag_ids = Array(params[:tag_ids])
      
      @saved_candidates = @saved_candidates
        .joins(resume: :resume_tags)
        .where(resume_tags: { tag_id: tag_ids })
        .group('saved_candidates.id')
        .having('COUNT(DISTINCT resume_tags.tag_id) = ?', tag_ids.length)
    end
  end

  def destroy
    @saved_candidate.destroy
    redirect_to saved_candidates_path, notice: 'Candidate was successfully removed from saved.'
  end

  private

  def set_saved_candidate
    @saved_candidate = current_user.saved_candidates.find(params[:id])
  end
end 