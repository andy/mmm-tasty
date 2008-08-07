class FeedbacksController < ApplicationController
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