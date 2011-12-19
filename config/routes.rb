ActionController::Routing::Routes.draw do |map|

  map.vote 'vote/:entry_id/:action', :controller => 'vote'
  map.global_fave 'global/fave/:id', :controller => 'faves', :action => 'create'
  map.global 'global/:action', :controller => 'global'

  # это главный сайт, mmm-tasty.ru или www.mmm-tasty.ru
  map.with_options :conditions => { :subdomain => /^(www|)$/, :domain => Regexp.new(::DOMAINS.join('|'))  } do |www|
    www.connect '', :controller => 'main', :action => 'index'

    www.main_feed 'main/feed/:action/:rating/:kind.xml', :controller => 'main_feed', :action => 'last', :rating => 'default', :kind => 'default', :requirements => { :rating => /[a-z]{3,20}/ }
    www.last 'main/last/:rating/:kind', :controller => 'main', :action => 'last', :rating => 'default', :kind => 'default'
    www.anonymous 'main/anonymous/:action/:id', :controller => 'anonymous'
    www.connect 'main/:action/:page', :controller => 'main', :page => /\d+/
    www.main 'main/:action', :controller => 'main'

    # account routes, jf helper methods
    www.login 'account/login', :controller => 'account', :action => 'login'
    www.logout 'account/logout', :controller => 'account', :action => 'logout'
    www.signup 'account/signup', :controller => 'account', :action => 'signup'
    www.lost_password 'account/lost_password', :controller => 'account', :action => 'lost_password'
    www.recover_password 'account/recover_password/:user_id/:secret', :controller => 'account', :action => 'recover_password'
    www.account 'account/:action', :controller => 'account'
    www.confirm 'confirm/:action', :controller => 'confirm'
    www.confirm_code 'confirm/code/:code', :controller => 'confirm', :action => 'code'
    www.admin 'admin/:action', :controller => 'admin'
    www.search 'search/:action/:id', :controller => 'search'
    www.tag_view 'tag/*tags', :controller => 'tags', :action => 'view'
    www.tags 'tags/:action/:id', :controller => 'tags'

    map.bookmarklet 'bookmarklet/:action', :controller => 'bookmarklet'

    www.resources :feedbacks, :member => { :publish => :post, :discard => :post }
  end

  # это домены пользователей: andy.mmm-tasty.ru, genue.mmm-tasty.ru и так далее
  map.with_options :controller => 'tlog' do |tlog|
    tlog.tlog '', :action => 'index'
    tlog.connect 'page/:page', :action => 'index', :page => /\d+/
    tlog.style 'style/:revision', :action => 'style', :revision => nil, :requirements => { :revision => /\d+/ }

    tlog.publish 'publish/:action/:id', :controller => 'publish'
    tlog.settings_social 'settings/social/:action', :controller => 'settings/social'
    tlog.settings_sidebar 'settings/sidebar/:action/:id', :controller => 'settings/sidebar'
    tlog.settings_mobile 'settings/mobile/:action/:id', :controller => 'settings/mobile'
    tlog.settings_premium 'settings/premium/:action/:id', :controller => 'settings/premium'
    tlog.settings 'settings/:action', :controller => 'settings/default'
    tlog.connect 'search/:action', :controller => 'search'
    tlog.connect 'tag/*tags', :controller => 'tags', :action => 'view'
    tlog.connect 'tags/:action/:id', :controller => 'tags'

    tlog.day ':year/:month/:day', :controller => 'tlog', :action => 'day', :requirements => { :year => /\d{4}/, :month => /\d{1,2}/, :day => /\d{1,2}/ }

    tlog.tlog_feed 'feed/:action.xml', :controller => 'tlog_feed'
    tlog.tlog_feed_protected 'feed/:key/:action.xml', :controller => 'tlog_feed'

    tlog.private_entries 'private', :action => 'private'
    tlog.anonymous_entries 'anonymous', :action => 'anonymous'

    tlog.resources :entries, :member => { :subscribe => :post, :unsubscribe => :post, :metadata => :get }, :collection => { :tags => :get, :relationship => :post } do |entry|
      entry.resources :comments, :new => { :preview => :post }
      entry.resources :tags, :controller => 'entry_tags', :name_prefix => 'entry_'
    end

    tlog.resources :messages, :controller => 'messages'
    tlog.resources :faves, :controller => 'faves'
  end

  map.catch_all "*anything", :controller => 'global', :action => 'not_found'
end