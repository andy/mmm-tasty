class EntrySweeper < ActionController::Caching::Sweeper
  observe Entry
  
  # создается новая статья
  def after_create(entry)
    expire_entry(entry)
  end
  
  # пользователь меняет информацию о себе
  def after_update(entry)
    expire_entry(entry)
  end
  
  # пользователь удален
  def after_destroy(entry)
    expire_entry(entry)
  end
  
  private
    # this code is also present in incomding_entry_handler.rb file, so be sure
    #  to fix it on updates too.
    def expire_entry(entry)
      expire_action(:controller => '/tlog_feed', :action => 'rss')
      expire_fragment(:controller => '/tlog', :action => 'index', :content_for => 'layout', :is_public => 'false', :page => entry.page_for(entry.author, false))
      expire_fragment(:controller => '/tlog', :action => 'index', :content_for => 'layout', :is_public => 'true', :page => entry.page_for(nil, false))
    end
end