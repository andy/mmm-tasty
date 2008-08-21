class MainFeedController < ApplicationController
  skip_before_filter :require_confirmation_on_current_user
  layout nil
  session :off

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
end
