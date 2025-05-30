class SavedCandidatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_saved_candidate, only: [:destroy]

  def index
    @saved_candidates = current_user.saved_candidates.includes(:resume)
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