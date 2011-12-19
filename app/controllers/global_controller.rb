class GlobalController < ApplicationController
  before_filter :require_current_user, :only => [:relationship, :relationship_destroy, :relationship_toggle, :pref_friends]

  def entry_metadata
    @entry = Entry.find(params[:entry_id])
    render :text => 'oops' and return if !@entry || (@entry.is_private? && current_user && @entry.user_id != current_user.id)
    render :partial => 'tlog/metadata', :locals => { :entry => @entry }
  end

  def test
    render :template => 'globals/empty', :layout => 'main'
  end

  def relationship
    @user = User.find(params[:user_id])
    @relationship = current_user.relationship_with(@user, true)
    render :layout => false
  end

  # эта функция расчитана на вызов из globals/pref_friends, где, в случае успешного удаления, она
  #  сначала подсветит, а потом удалит выбранного пользователя из списка
  def relationship_destroy
    render :nothing => true and return unless request.post?

    @user = User.find(params[:user_id])
    render :text => 'error' and return unless user

    current_user.set_friendship_status_for(@user, Relationship::GUESSED)
  end

  # переключает статус взаимоотношений между пользователями, вызывать можно как:
  #   link_to_remote ....., url => global_url(:action => 'relationship_toggle', :user_id => user), :update => 'pref_friends_holder'
  def relationship_toggle
    render :nothing => true and return unless request.post?

    @user = User.find(params[:user_id])
    render :text => 'invalid :user_id' and return unless @user

    relationship = current_user.relationship_with(@user, true)
    # если это новая запись, либо значение где-то меньше минимального видимого - выставляем в минимальное-видимое (default)
    @friendship_status = (relationship.new_record? || relationship.friendship_status < Relationship::DEFAULT) ? Relationship::DEFAULT : Relationship::GUESSED
    relationship.update_attributes!({ :friendship_status => @friendship_status })
    relationship.position = 0
    relationship.move_to_top
    @subscribed_to = current_user.subscribed_to?(@user)
  end

  # show a friends sidebar that drop's down from the heart
  def pref_friends
    render :nothing => true and return unless request.post?
  end

  def not_found
    render :status => 404
  end
end