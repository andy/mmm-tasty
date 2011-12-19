class SearchController < ApplicationController
  skip_before_filter :require_confirmation_on_current_user

  helper :main
  layout 'main'

  def index
    @adsense_enabled = true

    if current_site && params[:limit] == 'none'
      redirect_to search_url(:host => "www.mmm-tasty.ru", :query => params[:query])
      return
    elsif !current_site && params[:user_id]
      redirect_to search_url(:host => host_for_tlog(User.find(params[:user_id])), :query => params[:query])
      return
    end

    @page = params[:page].to_i rescue 1
    @page = 1 if @page <= 0

    # gone too far
    if @page <= 67
      options = {}
      if current_site
        options[:filter] = [['user_id', [current_site.id]]]
        if !current_user || current_user.id != current_site.id
          options[:filter] += [['is_private', 0]]
        end
      else
        options[:filter] = [['is_private', 0]]
      end
      options[:sort_mode] = [:attr_desc, 'created_at']
      options[:page] = @page if @page > 1
      options[:limit] = Entry::PAGE_SIZE
      options[:index] = 'entries,delta'

      @entries = Entry.find_with_sphinx(params[:query], :sphinx => options)
    else
      @page = 0
      @entries = []
    end

    # результаты отображаются внутри тлога если поиск выполнялся по индивидуальному тлогу
    render :layout => current_site ? 'tlog' : 'main'
  end
end