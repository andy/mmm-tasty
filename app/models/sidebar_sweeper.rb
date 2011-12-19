class SidebarSweeper < ActionController::Caching::Sweeper
  observe SidebarElement, SidebarSection

  def after_create(element)
    expire_sidebar
  end

  def after_update(element)
    expire_sidebar
  end

  def after_destroy(element)
    expire_sidebar
  end

  private
    def expire_sidebar
      expire_fragment(:controller => '/tlog', :action => 'index', :content_for => 'sidebar_sections')
    end
end