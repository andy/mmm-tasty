class MainController < ApplicationController
  skip_before_filter :require_confirmation_on_current_user

  def index
  end
  
  def about
  end
  
  def news
    news = User.find_by_url('news')
    total_pages = news.entries_count_for(news).to_pages
    @page = params[:page].to_i.reverse_page( total_pages ) rescue 1
    @entries = news.recent_entries({ :page => @page })
  end
  
  def last_redirect
    kind = params[:filter][:kind]
    rating = params[:filter][:rating]

    kind = 'any' unless Entry::KINDS.include?(kind.to_sym)
    rating = 'everything' unless EntryRating::RATINGS.include?(rating.to_sym)

    if current_user
      current_user.settings[:last_kind] = kind
      current_user.settings[:last_rating] = rating
      current_user.save
    end
    redirect_to last_url(:kind => kind, :rating => rating)
  end
  
  def last
    @adsense_enabled = true
    # @social_ads_enabled = true

    # подгружаем
    kind = params[:kind] || 'default'
    rating = params[:rating] || 'default'  
    
    # выставляем значения по-умолчанию
    kind = (current_user && current_user.settings[:last_kind]) || 'any' if kind == 'default'
    rating = (current_user && current_user.settings[:last_rating]) || 'good' if rating == 'default'
  
    kind = 'any' unless Entry::KINDS.include?(kind.to_sym)
    rating = 'good' unless EntryRating::RATINGS.include?(rating.to_sym)

    @filter = Struct.new(:kind, :rating).new(kind, rating)
    sql_conditions = "#{EntryRating::RATINGS[@filter.rating.to_sym][:filter]} AND #{Entry::KINDS[@filter.kind.to_sym][:filter]}"
    
    # высчитываем общее число записей и запоминаем в кеше
    cache_key = "entry_ratings_count_#{kind}_#{rating}"
    total = Cache.get(cache_key)
    if total.nil?
      total = EntryRating.count :conditions => sql_conditions
      Cache.put(cache_key, total, 1.minute)
    end
    logger.info "total entries: #{total}, pages: #{total.to_pages}"

    @entry_ratings = EntryRating.find :all, :page => { :current => params[:page].to_i.reverse_page(total.to_pages), :size => 15, :count => total }, :include => [:entry], :order => 'entry_ratings.id DESC', :conditions => sql_conditions
  end
  
  def live
    @adsense_enabled = true
    # @social_ads_enabled = true
    
    sql_conditions = 'entries.is_mainpageable = 1'
    
    # кешируем общее число записей, потому что иначе :page обертка будет вызывать счетчик на каждый показ
    cache_key = "entry_count_public"
    total = Cache.get(cache_key)
    if total.nil?
      total = Entry.count :conditions => sql_conditions
      Cache.put(cache_key, total, 1.minute)
    end

    @page = params[:page].to_i.reverse_page(total.to_pages)
    @entries = Entry.find :all, :conditions => sql_conditions, :page => { :current => @page, :size => Entry::PAGE_SIZE, :count => total }, :include => [:author, :rating, :attachments], :order => 'entries.id DESC'
  end
  
  def last_personalized
    @adsense_enabled = true

    redirect_to(last_url) and return unless current_user
    # выставляем пользователю ключ (и создаем новый если его не было еще)
    unless current_user.settings[:last_personalized_key]
      current_user.settings[:last_personalized_key] = String.random
      current_user.update_attributes(:settings => current_user.settings)
    end
    @last_personalized_key = current_user.settings[:last_personalized_key]

    # такая же штука определена в tlog_feed_controller.rb
    friend_ids = current_user.all_friend_r.map(&:user_id)
    @page = params[:page].to_i rescue 1
    @page = 1 if @page <= 0
    # еще мы тут обманываем с количеством страниц... потому что считать тяжело 
    @entries = Entry.find(:all, :order => 'entries.id DESC', :include => [:rating, :attachments, :author], :page => { :current => @page, :size => 15, :count => ((@page * 15) + 1) }, :conditions => "entries.user_id IN (#{friend_ids.join(',')}) AND entries.is_private = 0") unless friend_ids.empty?
    expires_in 5.minutes
  end
  
  def users
    @page = 1
    @users = User.popular(6).shuffle
    @title = 'пользователи в абсолютно случайной последовательности'
  end
  
  def new_users
    @page = params[:page].to_i rescue 1
    @page = 1 if @page <= 0
    @users = User.find(:all, :page => { :current => @page, :size => 6 }, :order => 'id DESC', :conditions => 'is_confirmed = 1 AND entries_count > 0')
    @title = 'все пользователи тейсти'
    render :action => 'users'
  end
  
  def random
    @adsense_enabled = true
    # ищем публичную запись которую можно еще на главной показать
    entry = Entry.find(params[:entry_id]) if params[:entry_id]
    max_id = Entry.maximum(:id)
    unless entry
      10.times do
        entry_id = Entry.find_by_sql("SELECT min(id) AS maximum FROM entries WHERE id > #{rand(max_id)} AND is_private = 0").first[:maximum]
        entry = Entry.find entry_id if entry_id
        break if entry
      end
    end
    if entry
      @time = entry.created_at
      @user = entry.author
      @entries = @user.recent_entries({ :page => 1, :time => @time }).to_a      
      @calendar = @user.calendar(@time)
      
      @others = User.find_by_sql("SELECT u.id, u.url, e.id AS day_first_entry_id, count(*) AS day_entries_count FROM users AS u LEFT JOIN entries AS e ON u.id = e.user_id WHERE e.created_at > '#{@time.midnight.to_s(:db)}' AND e.created_at < '#{@time.tomorrow.midnight.to_s(:db)}' AND u.is_confirmed = 1 AND u.entries_count > 1 GROUP BY e.user_id")
    end
  end
end