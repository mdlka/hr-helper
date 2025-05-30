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
      
      redirect_to @resume, notice: t('resumes.flash.processed')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def save_candidate
    if current_user.saved_candidates.create(resume: @resume)
      redirect_to saved_candidates_path, notice: t('resumes.flash.candidate_saved')
    else
      redirect_to @resume, alert: t('resumes.flash.error_saving')
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
      redirect_to root_path, alert: t('resumes.flash.unauthorized')
    end
  end
end 