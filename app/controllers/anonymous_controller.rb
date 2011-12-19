class AnonymousController < ApplicationController
  before_filter :require_admin, :only => [:toggle]

  layout 'main'
  helper :main, :comments

  # смотрим список записей
  def index
    @adsense_enabled = true
    sql_conditions = 'type="AnonymousEntry" AND is_disabled = 0'

    # кешируем общее число записей, потому что иначе :page обертка будет вызывать счетчик на каждый показ
    total = Rails.cache.fetch('entry_count_anonymous', :expires_in => 10.minutes) { Entry.count :conditions => sql_conditions }

    @page = params[:page].to_i.reverse_page(total.to_pages)

    @entry_ids = Entry.find :all, :select => 'entries.id', :conditions => sql_conditions, :page => { :current => @page, :size => Entry::PAGE_SIZE, :count => total }, :order => 'entries.id DESC'
    @entries = Entry.find_all_by_id @entry_ids.map(&:id), :order => 'entries.id DESC'
  end

  def toggle
    @entry = Entry.find_by_id_and_type params[:id], 'AnonymousEntry'
    @entry.toggle!(:is_disabled)
    Rails.cache.delete('entry_count_anonymous')

    render :update do |page|
      page.visual_effect :highlight, dom_id(@entry, :toggle)
    end
  end

  # смотрим запись
  def show
    @adsense_enabled = true
    @entry = Entry.find_by_id_and_type params[:id], 'AnonymousEntry'

    redirect_to :action => 'index' and return unless @entry
    redirect_to :action => 'index' and return if @entry.is_disabled?

    @comment = Comment.new_from_cookie(cookies['comment_identity']) if !current_user && !cookies['comment_identity'].blank?
    @comment ||= Comment.new

    @last_comment_viewed = current_user ? CommentViews.view(@entry, current_user) : 0
  end

  # удаляем комментарий
  def comment_destroy
    render :nothing => true and return unless request.delete?

    @comment = Comment.find_by_id(params[:id])
    @comment.destroy if current_user && @comment.is_owner?(current_user)

    respond_to do |wants|
      wants.html { flash[:good] = 'Комментарий был удален'; redirect_to anonymous_url(:action => 'show', :id => @comment.entry_id) }
      wants.js # comment_destroy.rjs
    end
  end

  # добавляем комментарий
  def comment
    render :nothing => true and return unless request.post?

    @entry = Entry.find_by_id_and_type params[:id], 'AnonymousEntry'
    render(:text => 'oops, entry not found') and return unless @entry
    render(:text => 'oops, entry deleted') and return if @entry.is_disabled?
    render(:text => 'comments disabled for this entry, sorry') and return unless @entry.comments_enabled?
    render(:text => 'sorry, anonymous users are not allowed to comment') and return unless current_user
    render(:text => 'sorry, you need to confirm your email address first') and return  unless current_user.is_confirmed?

    user = current_user if current_user
    @comment = Comment.new(params[:comment])
    @comment.user = user
    @comment.request = request
    @comment.entry_id = @entry.id
    @comment.valid?

    if @comment.errors.empty?
      @comment.save!

      users = []
      if !params[:reply_to].blank?
        comment_ids = params[:reply_to].split(',').map(&:to_i)
        # выбирает все комментарии для этой записи и достаем оттуда уникальных пользователей
        reply_to = Comment.find(comment_ids, :conditions => "entry_id = #{@entry.id}").map(&:user_id).reject { |id| id <= 0 }.uniq
        users = User.find(reply_to).reject { |user| !user.email_comments? }
      end

      # отправляем комментарий владельцу записи
      if @entry.author.is_emailable? && @entry.author.email_comments? && (!current_user || @entry.user_id != current_user.id)
        EmailConfirmationMailer.deliver_comment(@entry.author, @comment)
      end

      # отправляем комменатрий каждому пользователю
      users.each do |user|
        EmailConfirmationMailer.deliver_comment_reply(user, @comment) if user.is_emailable? && user.email_comments? && user.id != @entry.author.id
      end

      # отправляем сообщение всем тем, кто наблюдает за этой записью, и кому мы еще ничего не отправляли
      (@entry.subscribers - users).each do |user|
        EmailConfirmationMailer.deliver_comment_to_subscriber(user, @comment) if user.is_emailable? && user.email_comments? && user.id != current_user.id
      end

      # автоматически подписываем пользователя если на комментарии к этой записи если он еще не подписан
      @entry.subscribers << current_user if current_user && current_user.comments_auto_subscribe? && @entry.user_id != current_user.id && !@entry.subscribers.map(&:id).include?(current_user.id)
    end

    respond_to do |wants|
      wants.html { redirect_to anonymous_url(:action => :show, :id => @entry.id); }
      wants.js # create.rjs
    end
  end

  # предпросматриваем комментарий
  def preview
    render :nothing => true and return unless request.post?
    render :text => 'sorry, anonymous users are not allowed' and return unless current_user

    @entry = Entry.find_by_id_and_type params[:id], 'AnonymousEntry'

    render(:text => 'oops, entry not found') and return unless @entry
    render(:text => 'oops, entry deleted') and return if @entry.is_disabled?

    @comment = Comment.new(params[:comment])
    @comment.user = current_user if current_user
    @comment.remote_ip = request.remote_ip
    @comment.valid?

    render :update do |page|
      page.call :clear_all_errors
      # если есть ошибки...
      if @comment.errors.size > 0
        @comment.errors.each do |element, message|
          page.call :error_message_on, "comment_#{element}", message
        end
      else
        # иначе рендерим темлплейт
        page.replace_html 'comment_preview', :partial => 'preview'
      end
    end
  end
end