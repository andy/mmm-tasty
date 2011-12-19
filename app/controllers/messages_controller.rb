class MessagesController < ApplicationController
  before_filter :require_current_site, :require_confirmed_current_site
  before_filter :require_confirmed_current_user, :only => [:create, :destroy]
  before_filter :require_messages_enabled

  def index
    @messages = Message.find_for_user(:site => current_site, :user => current_user, :page => { :size => 10, :current => params[:page] })
    render :layout => 'tlog'
  end

  # POST messages_url
  def create
    @message            = Message.new params[:message]
    @message.sender     = current_user
    @message.user       = current_site
    @message.save
    EmailConfirmationMailer.deliver_message(current_site, @message) if @message.valid? && @message.sender_id != current_site.id && current_site.is_emailable? && current_site.tlog_settings.email_messages?
  end

  # DELETE message_url(@message)
  def destroy
    @message = Message.find(params[:id])
    @message.destroy if @message.is_owner?(current_user)
  end

  private
    def require_messages_enabled
      !current_site.tlog_settings.sidebar_hide_messages?
    end
end