class Settings::MobileController < ApplicationController
  before_filter :require_current_user, :current_user_eq_current_site
  before_filter :require_confirmed_current_user

  helper :settings
  layout "settings"

  def email
    # create mobile settings thing
    current_user.mobile_settings ||= MobileSettings.create :user => current_user, :keyword => MobileSettings.generate_keyword

    # update mobile settings if post request
    current_user.mobile_settings.update_attributes(:keyword => MobileSettings.generate_keyword) if request.post?

    # used in views
    @private_email = "#{current_user.mobile_settings.keyword}@mmm-tasty.ru"

    respond_to do |wants|
      logger.info wants.class
      wants.html # email.rhtml
      wants.js do
        render :update do |page|
          page.replace_html :private_email, @private_email
          page.visual_effect :highlight, :private_email, { :duration => 0.3 }
        end
      end
    end
  end

  def sms
  end

  def bookmarklets
    @bookmarklet = Bookmarklet.find_by_id_and_user_id(params[:id], current_user.id) if params[:id]
    @bookmarklet ||= Bookmarklet.new

    if request.post?
      @bookmarklet.attributes = params[:bookmarklet]
      @bookmarklet.user = current_user
      if @bookmarklet.save
        flash[:good] = 'Закладка была сохранена'
        redirect_to :action => :bookmarklets, :id => nil
      else
        flash[:bad] = 'Не сохранили закладку из-за ошибки'
      end
    end
  end

  def bookmarklet_destroy
    @bookmarklet = Bookmarklet.find_by_id_and_user_id(params[:id], current_user.id)
    @bookmarklet.destroy
  end
end