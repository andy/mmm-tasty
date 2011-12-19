class Settings::SocialController < ApplicationController
  before_filter :require_current_user, :current_user_eq_current_site
  before_filter :require_confirmed_current_user
  after_filter :expire_cache, :only => [:delete, :title_update, :add, :sort]

  helper :settings
  layout "settings"

  def index
    @light = false
    @new_user = User.new
  end

  def light
    @light = true
    @disable_css = true
    @new_user = User.new
    render :layout => false
  end

  def delete
    render :nothing => true and return unless request.post?
    relationship = Relationship.find(params[:relationship_id], :conditions => "reader_id = #{current_user.id}") rescue nil
    relationship.destroy if relationship
    render :nothing => true
  end

  def title
    @relationship = Relationship.find(params[:relationship_id], :conditions => "reader_id = #{current_user.id}")
    user = @relationship.user
    render :update do |page|
      page.replace_html user.dom_id(:title_editor), :partial => 'title_editor'
      page.visual_effect :highlight, user.dom_id(:title_editor)
    end
  end

  def title_update
    render :nothing => true and return unless request.post?

    @relationship = Relationship.find(params[:relationship_id], :conditions => "reader_id = #{current_user.id}")
    user = @relationship.user

    title = params[:title].strip rescue ''
    @relationship.update_attributes!({ :title => title })
    render :update do |page|
      page[user.dom_id(:title_editor)].update(content_tag(:span, h(title)))
      page.visual_effect :highlight, user.dom_id(:title_editor)
    end
  end

  def add
    user = User.find_by_url(params[:url])
    friendship_status = params[:friendship_status]
    unless user && user.id != current_user.id
      render :update do |page|
        page.call :clear_all_errors
        page.call :error_message_on, :new_user_url, 'такой пользователь не найден'
      end
      return
    end

    new_relationship = true # вставлять объект в страницу? не нужно делать если relationship существует
    move_relationship = false
    relationship = current_user.relationship_with(user, false)
    if relationship
      if friendship_status != relationship.friendship_status
        relationship.update_attributes!( :friendship_status => friendship_status )
        move_relationship = true
      else
        new_relationship = false
      end
    else
      relationship = current_user.set_friendship_status_for(user, friendship_status)
      relationship.move_to_bottom
    end

    # Перезагружаем пользователья в смесь User+Relationship. Именно такой объект ожидает partial _user.rhtml
    @user = current_user.relationship_as_user_with(user)
    render :update do |page|
      page.call :clear_all_errors
      page.remove "relationship_#{@user.relationship_id}" if move_relationship
      if new_relationship
        page.insert_html :bottom, (relationship.friendship_status == 2 ? :public_friends : :friends), :partial => 'user'
        page.draggable "relationship_#{@user.relationship_id}", :revert => true
      end
      page.visual_effect :highlight, "relationship_#{@user.relationship_id}"
      page[:new_user_url].value = ''
    end
  end

  def sort
    sorts = { 'public_friends' => 2, 'friends' => 1, 'guessed' => 0, 'delete' => -1 }
    sort_key = (sorts.keys.to_a & params.keys.to_a).first
    render(:text => 'no sort key, nothing to do', :status => 200) and return unless params[sort_key]
    render(:nothing => true) and return if sort_key == 'delete'
    items = params[sort_key].map { |item| item.to_i }.reject { |item| item <= 0 }
    friendship_status = sorts[sort_key]

    relationships = Relationship.find_by_sql("SELECT * FROM relationships WHERE id IN (#{items.join(',')}) AND reader_id = #{current_user.id}")
    relationships.each do |relationship|
      position = items.index(relationship.id) + 1
      if position != relationship.position || friendship_status != relationship.friendship_status
        relationship.position = position
        relationship.friendship_status = friendship_status
        # execute raw sql query
        relationship.connection.update("UPDATE relationships SET position = #{relationship.position}, friendship_status = #{relationship.friendship_status} WHERE id = #{relationship.id}")
      end
    end
    render :nothing => true
  end

  private
    def expire_cache
      expire_fragment(:controller => '/tlog', :action => 'index', :content_for => 'public_friends')
    end
end