class TlogFeedController < ApplicationController
  layout nil
  session :off
  before_filter :require_current_site
  caches_action :rss, :photos, :last_personalized, :cache_path => Proc.new { |c| c.url_for(:expiring => (Time.now.to_i / 15.minutes).to_i, :page => c.params[:page]) }

  def rss
    @entries = current_site.recent_entries.to_a
    response.headers['Content-Type'] = 'application/rss+xml'
  end

  def photos
    @page = (params[:page] || 1).to_i
    @entries = Entry.find :all, :conditions => "entries.user_id = #{current_site.id} AND entries.is_private = 0 AND entries.type = 'ImageEntry'", :page => { :current => @page, :size => 30, :count => ((@page * 30) + 1) }, :order => 'entries.id DESC', :include => [:author, :attachments]
    response.headers['Content-Type'] = 'application/rss+xml'
    render :action => 'media'
  end

  def last_personalized
    render(:text => 'invalid key, sorry', :status => 403) and return if current_site.last_personalized_key != params[:key]
    friend_ids = current_site.all_friend_r.map(&:user_id)
    unless friend_ids.blank?
      @entry_ids = Entry.find :all, :select => 'entries.id', :conditions => "entries.user_id IN (#{friend_ids.join(',')}) AND entries.is_private = 0", :order => 'entries.id DESC', :limit => 15
      @entries = Entry.find_all_by_id @entry_ids.map(&:id), :include => [:rating, :attachments, :author], :order => 'entries.id DESC'
    end
    response.headers['Content-Type'] = 'application/rss+xml'
  end

  private
    def require_current_site
      render(:text => 'тлога по этому адресу не существует', :status => 404) and return false unless current_site
      render(:text => 'пользователь не подтвержден', :status => 403) and return false unless current_site.is_confirmed?
    end
end
