class FavesController < ApplicationController
  before_filter :require_current_site, :except => [:create]
  before_filter :require_confirmed_current_site, :except => [:create, :destroy]
  before_filter :require_current_user, :only => [:create, :destroy]

  layout 'tlog'

  def index
    @page = params[:page].to_i.reverse_page(current_site.faves.size.to_pages)
    @faves = Fave.find :all, :page => { :current => @page, :size => 15, :count => current_site.faves.size }, :include => { :entry => [:attachments, :author, :rating] }, :order => 'faves.id DESC', :conditions => { :user_id => current_site.id }
  end

  # попадаем сюда через global/fave
  def create
    entry = Entry.find params[:id]
    render :text => 'entry not found' and return unless entry

    fave = Fave.find_or_initialize_by_user_id_and_entry_id current_user.id, entry.id
    if fave.new_record? && !entry.is_private? && entry.user_id != current_user.id
      fave.entry_type = entry[:type]
      fave.entry_user_id = entry.user_id
      fave.save
    end

    render :update do |page|
      page.visual_effect :highlight, entry.dom_id(:fave)
    end
  end

  def destroy
    entry = Entry.find params[:id]
    render :text => 'entry not found' and return unless entry

    fave = Fave.find_by_user_id_and_entry_id current_site.id, entry.id
    fave.destroy if fave && fave.is_owner?(current_user)

    render :update do |page|
      page.visual_effect :fade, entry.dom_id
    end
  end
end