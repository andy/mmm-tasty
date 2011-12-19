class PublishController < ApplicationController
  before_filter :require_current_user, :current_user_eq_current_site, :filter_entry

  def index
  end

  def preview
    render :nothing => true and return unless request.post?
    if params[:entry][:id]
      @entry = Entry.find_by_id_and_user_id(params[:entry][:id], current_user.id)
      @entry.has_attachment = !@entry.attachments.empty?
    else
      type = params[:entry][:type] rescue 'TextEntry'
      @entry = type.constantize.new
      @entry.author = current_user
      @entry.has_attachment = false
    end
    @entry.attributes = params[:entry]
    @entry.valid?
    render :update do |page|
      page.call :clear_all_errors

      if @entry.errors.size > 0
        page.replace_html 'preview_holder', ''
        @entry.errors.each do |element, message|
          page.call :error_message_on, "entry_#{element}", message
        end
      else
        page.replace_html 'preview_holder', :partial => 'preview'
      end
    end
  end

  def text
    process_entry_request 'TextEntry'
  end

  def link
    process_entry_request 'LinkEntry'
  end

  def quote
    process_entry_request 'QuoteEntry'
  end

  def image
    process_entry_request 'ImageEntry'
  end

  def song
    process_entry_request 'SongEntry'
  end

  def video
    process_entry_request 'VideoEntry'
  end

  def convo
    process_entry_request 'ConvoEntry'
  end

  def code
    process_entry_request 'CodeEntry'
  end

  def anonymous
    process_entry_request 'AnonymousEntry'
  end

  private
    # страница для произвольной записи
    def process_entry_request(type)
      klass = type.constantize
      @new_record = true
      @attachment = nil
      # @ad = nil

      if !current_user.can_create?(klass) && !params[:id]
        @entry = klass.new
        render :action => 'limit_exceeded'
        return
      end

      if request.post?
        # редактирование уже существующей записи
        if params[:id]
          @entry = Entry.find_by_id_and_user_id(params[:id], current_user.id)
          @entry.has_attachment = !@entry.attachments.empty? if @entry
          @entry = nil if @entry && @entry.class.to_s != type
        end

        if @entry.nil?
          @entry = klass.new
          @entry.has_attachment = params[:attachment] && !params[:attachment][:uploaded_data].blank?
          @entry.author = current_user
          @entry.visibility = @entry.is_anonymous? ? 'private' : current_user.tlog_settings.default_visibility
          logger.info "creating new entry of type #{type}" if @entry.new_record?
        end

        @new_record = @entry.new_record?
        @entry.attributes = params[:entry]
        if @entry.visibility != 'voteable' || @new_record
          @entry.visibility = params[:entry][:visibility] || current_user.tlog_settings.default_visibility
        end unless @entry.is_anonymous?
        @entry.comments_enabled = current_user.tlog_settings.comments_enabled?
        # unless @entry.ad
        #   # добавляем только в том случае, если у записи еще нет рекламного блока
        #   @entry.ad = SocialAd.new :user => current_user, :annotation => params[:ad][:annotation] if @entry.visibility == 'voteable' && params[:ad][:annotation]
        # end
        # @entry.is_voteable = params[:entry][:is_voteable] if @entry.new_record? && !current_user.is_limited?
        @entry.tag_list = params[:entry][:tag_list]
        Entry.transaction do
          @new_record = @entry.new_record?
          @entry.save!
          # @entry.ad.save! if @entry.ad && @entry.ad.new_record?

          if @entry.can_have_attachments? && @entry.has_attachment && @new_record
            @attachment = Attachment.new params[:attachment]
            logger.info "adding attachment to entry id = #{@entry.id}"
            @attachment.entry = @entry
            @attachment.user = current_user
            @attachment.save!
          end

          @entry.make_voteable(true) if @entry.is_voteable?
        end
        if in_bookmarklet?
          redirect_to bookmarklet_url(:host => "www.mmm-tasty.ru", :action => 'published')
        else
          redirect_to url_for_entry(@entry)
        end
        return
      else
        if params[:id]
          @entry = Entry.find_by_id_and_user_id(params[:id], current_user.id)
          if @entry.nil?
            redirect_to publish_url(:id => nil)
            return
          end
          # @ad = @entry.ad
        end
        @entry ||= in_bookmarklet? ? klass.new_from_bm(params[:bm]) : klass.new
        @new_record = @entry.new_record?
        if in_bookmarklet?
          @entry.tag_list.add(params[:bm][:tags]) if params[:bm][:tags]
          visibility = params[:bm][:vis] if params[:bm][:vis]
          @entry.visibility = visibility || current_user.tlog_settings.default_visibility
        else
          # выставляем флаг видимости в значение по-умолчанию, сама модель этого сделать не может
          @entry.visibility = current_user.tlog_settings.default_visibility if @new_record
        end
        @attachment = Attachment.new
      end

      # @ad = @entry.ad || SocialAd.new(:annotation => params[:ad] ? params[:ad][:annotation] : nil)
      render :action => 'edit'
    rescue ActiveRecord::RecordInvalid => e
      # @ad = @entry.ad
      # @ad.valid? unless @ad.nil? # force error checking
      @attachment.valid? unless @attachment.nil? # force error checking
      render :action => 'edit'
    end

    # проверяем что entry.type имеет допустимое значение
    def filter_entry
      return true unless params[:entry] && params[:entry][:type]
      return true if %w( TextEntry LinkEntry QuoteEntry ImageEntry SongEntry VideoEntry ConvoEntry CodeEntry AnonymousEntry).include?(params[:entry][:type])
      render :text => 'oops, bad entry type', :status => 403
      false
    end

    def in_bookmarklet?
      !!params[:bm]
    end
    helper_method :in_bookmarklet?
end
