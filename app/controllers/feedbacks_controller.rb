class FeedbacksController < ApplicationController
  before_filter :require_admin, :except => [:create, :destroy]
  helper :main

  # GET feedbacks_url
  def index
    @feedbacks = Feedback.pending.paginate :page => params[:page], :per_page => 15, :include => [:user]

    render :layout => 'main'
  end

  # POST publish_feedback_path(@feedback)
  def publish
    @feedback = Feedback.find params[:id]
    @feedback.publish!

    render :update do |page|
      page.visual_effect :fade, @feedback.dom_id, :duration => 0.3
    end
  end

  # POST discard_feedback_path(@feedback)
  def discard
    @feedback = Feedback.find params[:id]
    @feedback.discard!

    render :update do |page|
      page.visual_effect :fade, @feedback.dom_id, :duration => 0.3
    end
  end

  # POST feedbacks_url
  def create
    @feedback = Feedback.new params[:feedback]
    @feedback.user = current_user
    @feedback.save
  end

  # DELETE feedback_url(@feedback)
  def destroy
    @feedback = Feedback.find(params[:id])
    @feedback.destroy if @feedback.is_owner?(current_user)
  end
end