class TlogFeedController < ApplicationController
  layout nil
  session :off
  before_filter :require_current_site
  caches_action :rss, :last_personalized

  def rss
    @entries = current_site.recent_entries.to_a
    response.headers['Content-Type'] = 'application/rss+xml'
  end
  
  def last_personalized
    render(:text => 'invalid key, sorry', :status => 403) and return if current_site.settings[:last_personalized_key] != params[:key]
    friend_ids = current_site.all_friend_r.map(&:user_id)
    @entries = Entry.find(:all, :limit => 10, :order => 'entries.id DESC', :conditions => "entries.user_id IN (#{friend_ids.join(',')}) AND entries.is_private = 0", :include => [:attachments]) unless friend_ids.empty?
    response.headers['Content-Type'] = 'application/rss+xml'
    response.time_to_live = 30.minutes
  end

  private
    def require_current_site
      render(:text => 'there is no such user', :status => 404) and return false unless current_site
      render(:text => 'user is not confirmed', :status => 403) and return false unless current_site.is_confirmed?
    end
end
