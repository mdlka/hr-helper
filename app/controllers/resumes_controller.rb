class ResumesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :set_resume, only: [:show, :save_candidate]
  before_action :check_resume_access, only: [:show]

  def new
    @resume = Resume.new
  end

  def create
    @resume = Resume.new(resume_params)
    @resume.user = current_user if user_signed_in?

    processor = ResumeProcessorService.new
    summary, tags = processor.process(@resume.content)
    
    @resume.summary = summary
    
    if @resume.save
      @resume.tags = tags
      
      redirect_to @resume, notice: 'Resume was successfully processed.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def save_candidate
    saved_candidate = current_user.saved_candidates.new(resume: @resume)
    
    if saved_candidate.save
      redirect_to saved_candidates_path, notice: 'Candidate was successfully saved.'
    else
      redirect_to @resume, alert: 'Unable to save candidate.'
    end
  end

  private

  def set_resume
    @resume = Resume.find(params[:id])
  end

  def resume_params
    params.require(:resume).permit(:content)
  end

  def check_resume_access
    unless @resume.user == current_user || current_user.saved_candidates.exists?(resume: @resume)
      redirect_to root_path, alert: 'You are not authorized to view this resume.'
    end
  end
end 