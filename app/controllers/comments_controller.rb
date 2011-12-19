class CommentsController < ApplicationController
  before_filter :require_current_site, :find_entry

  def preview
    render :nothing => true and return unless request.post?

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

  # POST /entry/:entry_id/comments
  # Есть три типа пользователей которые могут оставлять комментарии:
  #  1- анонимные
  #  2- зарегистрированные анонимно, но для которых выставляется current_user (ограничения такие же как у 1.)
  #  3- зарегистрированные (индивидуальные ограничения)
  # у каждого из них имеются свои ограничения
  def create
    user = current_user if current_user
    @comment = Comment.new(params[:comment])
    @comment.user = user
    @comment.request = request
    @comment.entry_id = @entry.id
    @comment.valid?

    if @comment.errors.empty?
      @comment.save!
      current_user.comments(current_site) if current_user

      users = []
      if !params[:reply_to].blank?
        comment_ids = params[:reply_to].split(',').map(&:to_i)
        # выбирает все комментарии для этой записи и достает оттуда уникальных пользователей
        reply_to = Comment.find(comment_ids, :conditions => "entry_id = #{@entry.id}").map(&:user_id).reject { |id| id <= 0 }.uniq
        users = User.find(reply_to).reject { |user| !user.email_comments? }
      end

      # отправляем комментарий владельцу записи
      if current_site.is_emailable? && current_site.email_comments? && (!current_user || current_site.id != current_user.id)
        EmailConfirmationMailer.deliver_comment(current_site, @comment)
      end

      # отправляем комменатрий каждому пользователю
      users.each do |user|
        EmailConfirmationMailer.deliver_comment_reply(user, @comment) if user.is_emailable? && user.email_comments? && user.id != current_site.id
      end

      # отправляем сообщение всем тем, кто наблюдает за этой записью, и кому мы еще ничего не отправляли
      (@entry.subscribers - users).each do |user|
        EmailConfirmationMailer.deliver_comment_to_subscriber(user, @comment) if user.is_emailable? && user.email_comments? && user.id != current_user.id
      end

      # автоматически подписываем пользователя если на комментарии к этой записи если он еще не подписан
      @entry.subscribers << current_user if current_user && current_user.comments_auto_subscribe? && @entry.user_id != current_user.id && !@entry.subscribers.map(&:id).include?(current_user.id)

      unless current_user
        cookies['comment_identity'] = { :value => @comment.pack_for_cookie, :expires => 10.years.from_now, :domain => request.domain }
      end
      respond_to do |wants|
        wants.html { redirect_to entry_url(@entry); }
        wants.js { render :update do |page|
          page.call :clear_all_errors
          page.call 'window.location.reload'

          ## this does not work in safari:
          # redirect_to entry_url(@entry)
        end }
      end
    else
      render :update do |page|
        page.call :clear_all_errors
        @comment.errors.each do |element, message|
          page.call :error_message_on, "comment_#{element}", message
          page.call :error_message_on, "comment_ext_username", message if element == 'user_id' # добавляем
        end
      end
    end
  end

  def destroy
    # пока что мы позволяем удалять комменатрии только зарегистрированным пользователям
    if current_user
      @comment = Comment.find_by_id_and_entry_id(params[:id], @entry.id)
      @comment.destroy if @comment && @comment.is_owner?(current_user)
    end

    respond_to do |wants|
      wants.html { flash[:good] = 'Комментарий был удален'; redirect_to entry_url(@entry) }
      wants.js {
        render :update do |page|
          page.replace_html 'top_comment_number', @entry.comments.size - 1
          if @comment
            page.visual_effect(:highlight, dom_id(@comment), :duration => 0.1, :endcolor => '"#eb7979"' )
            page.visual_effect(:fade, dom_id(@comment))
          end
        end
      }
    end

  end

  private
    # проверка доступа к комментированию записи.
    def find_entry
      @entry = Entry.find_by_id_and_user_id(params[:entry_id], current_site.id)
      render(:text => "bad entry id, sorry") and return false \
              unless @entry

      if params[:action] != 'destroy'
        render(:text => "comments disabled for this entry, sorry, #{params[:action]}") and return false \
              unless @entry.comments_enabled?
      end

      render(:text => 'sorry, anonymous users are not allowed to comment') and return false \
              unless current_user

      render(:text => 'sorry, you need to confirm your email address first') and return false \
              unless current_user.is_confirmed?

      true
    end
end
