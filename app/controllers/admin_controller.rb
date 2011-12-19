class AdminController < ApplicationController
  before_filter :require_admin_or_production_preview_env

  def index
  end

  # функция переключения между режимами
  def switch
    redirect_to_address = request.env['HTTP_REFERER'] ? request.env['HTTP_REFERER'] : (current_user ? url_for_tlog(current_user) : 'http://www.mmm-tasty.ru/')

    if RAILS_ENV == 'development'
      cookies[:css] = { :value => '', :expires => Time.now, :domain => request.domain }
      cookies[:env] = { :value => '', :expires => Time.now, :domain => request.domain }
      flash[:good] = "С возвращением в настоящий мир#{(', ' + current_user.url) if current_user}!"
    else
      cookies[:css] = { :value => 'http://www.mmm-tasty.ru/stylesheets/genue/css/', :expires => 1.year.from_now, :domain => request.domain }
      cookies[:env] = { :value => 'new-secret-for-the-future', :expires => 1.year.from_now, :domain => request.domain }
      flash[:good] = "Добро пожаловать в мир отладки#{(', ' + current_user.url) if current_user}!"
    end
    redirect_to redirect_to_address
  end

  def css
    if request.post?
      css = (params[:css].to_s if params[:css]) || nil

      if css
        css += '/' unless css.ends_with?('/')
        cookies[:css] = { :value => css, :expires => 1.year.from_now, :domain => request.domain }
      else
        cookies[:css] = { :value => '', :expires => Time.now, :domain => request.domain }
      end
      flash[:good] = "CSS файлы будут подгружаться с адреса: #{css || "http://www.mmm-tasty.ru/stylesheets/"}"
      redirect_to admin_url(:action => 'css')
    else
      @css = !request.cookies['css'].blank? ? request.cookies['css'].value.to_s : "http://www.mmm-tasty.ru/stylesheets/"
    end
  end

  def server
    if request.post?
      env = params[:env]
      if env == 'development'
        cookies[:env] = { :value => 'new-secret-for-the-future', :expires => 1.year.from_now, :domain => request.domain }
        flash[:good] = "Вы перешли на сервер с хрупким, нестабильным кодом с массой ошибок"
      else
        cookies[:env] = { :value => '', :expires => Time.now, :domain => request.domain }
        flash[:good] = "Вы перешли на стабильный, дважды ускоренный сервер, который видит весь мир"
      end
      redirect_to admin_url(:action => 'server')
    end
  end

  private
    def require_admin_or_production_preview_env
      RAILS_ENV == 'development' || (current_user && current_user.is_admin?)
    end
end
