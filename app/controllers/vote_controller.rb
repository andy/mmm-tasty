class VoteController < ApplicationController
  before_filter :require_current_user, :require_voteable_entry_id

  def up; vote(1) end
  def down; vote(-1) end

  private
    def vote(rating)
      @entry.vote(current_user, rating)
      render :update do |page|
        page.replace_html "entry_rating_#{@entry.id}", "#{@entry.rating.value}"
      end
    end

    def require_voteable_entry_id
      @entry = Entry.find(params[:entry_id]) rescue nil
      render(:text => 'sorry, entry not found') and return false unless @entry
      render(:text => 'sorry, entry is not voteable') and return false unless @entry.is_voteable?
      render(:text => 'sorry, you cant vote for this entry') and return false unless current_user.can_vote?(@entry)
      true
    end
end