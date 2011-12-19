class BookmarkletController < ApplicationController
  before_filter :require_current_user
  before_filter :require_confirmed_current_user

  def new
    # копируем только нужные параметры в :bm
    options = %w(url title c tags vis autosave).inject({}) { |opts, k| opts.update("bm[#{k}]" => params[k] ? params[k].strip : nil) }
    options.merge!({ :host => host_for_tlog(current_user) })
    options.merge!({ :action => params[:type] }) if params[:type]
    redirect_to publish_url(options)
  end

  def published
  end
end
