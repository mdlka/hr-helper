class SavedCandidatesController < ApplicationController
  before_action :authenticate_user!

  def index
    @saved_candidates = current_user.saved_candidates.includes(resume: :tags)

    @tags = Tag.joins(resumes: :saved_candidates)
              .where(saved_candidates: { user_id: current_user.id })
              .distinct
              .order(:name)

    if params[:tag_ids].present?
      tag_ids = Array(params[:tag_ids])

      @saved_candidates = @saved_candidates
        .joins(resume: :resume_tags)
        .where(resume_tags: { tag_id: tag_ids })
        .group("saved_candidates.id")
        .having("COUNT(DISTINCT resume_tags.tag_id) = ?", tag_ids.length)
    end
  end

  def destroy
    @saved_candidate = current_user.saved_candidates.find(params[:id])
    @saved_candidate.destroy
    redirect_to saved_candidates_path, notice: t("saved_candidates.flash.removed")
  end
end
