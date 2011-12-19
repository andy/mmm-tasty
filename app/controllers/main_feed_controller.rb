class MainFeedController < ApplicationController
  skip_before_filter :require_confirmation_on_current_user
  layout nil
  session :off
  caches_action :live, :last, :photos, :cache_path => Proc.new { |c| c.url_for(:expiring => (Time.now.to_i / 15.minutes).to_i, :page => c.params[:page]) }

  def last
    ### такая же штука определена в main_controller.rb

    # подгружаем
    kind = params[:kind] || 'default'
    rating = params[:rating] || 'default'

    # выставляем значения по-умолчанию
    kind = 'any' if kind == 'default'
    rating = 'good' if rating == 'default'

    kind = 'any' unless Entry::KINDS.include?(kind.to_sym)
    rating = 'good' unless EntryRating::RATINGS.include?(rating.to_sym)

    @filter = Struct.new(:kind, :rating).new(kind, rating)
    @entry_ratings = EntryRating.find :all, :include => [:entry], :limit => 15, :order => 'entry_ratings.id DESC', :conditions => "#{EntryRating::RATINGS[@filter.rating.to_sym][:filter]} AND #{Entry::KINDS[@filter.kind.to_sym][:filter]}"
    @entries = @entry_ratings.map { |er| er.entry }

    response.headers['Content-Type'] = 'application/rss+xml'
  end

  def live
    @entries = Entry.find :all, :conditions => 'entries.is_private = 0 AND entries.is_mainpageable = 1', :order => 'entries.id DESC', :include => [:author, :attachments], :limit => 15
    response.headers['Content-Type'] = 'application/rss+xml'

    render :action => 'last'
  end

  def photos
    @page = (params[:page] || 1).to_i
    @entries = Entry.find :all, :conditions => "entries.is_private = 0 AND entries.is_mainpageable = 1 AND entries.type = 'ImageEntry'", :page => { :current => @page, :size => 50, :count => ((@page + 1) * 50) }, :order => 'entries.id DESC', :include => [:author, :attachments]
    response.headers['Content-Type'] = 'application/rss+xml'
    render :template => 'tlog_feed/media'
  end
end
