class ConfirmController < ApplicationController
  before_filter :require_current_user, :only => [:required, :resend]
  before_filter :redirect_home_if_current_user_is_confirmed, :except => [:code]
  layout 'account'

  def required
  end

  def resend
    if request.post?
      current_user.update_confirmation!(current_user.email)
      EmailConfirmationMailer.deliver_confirm(current_user, current_user.email)
      flash[:good] = "Загляните, пожалуйста, в почтовый ящик #{current_user.email}, там должно быть письмо с кодом подтверждения"
    end
    redirect_to confirm_url(:action => :required)
  end

  # /confirm/code/13_4efeb9ce
  def code
    user = User.find(params[:code].split(/_/)[0].to_i) rescue nil
    render_tasty_404('Ошибка. Указанный код подтверждения не был найден') and return unless user
    email = user.validate_confirmation(params[:code])
    render_tasty_404('Ошибка. Указанный код подтверждения не работает') and return unless email

    user.email = (email || user.email)
    was_confirmed = user.is_confirmed?
    user.is_confirmed = true
    user.clear_confirmation
    if user.save
      # выставляем новую авторизационную куку, но только если он не по openid авторизуется
      cookies['login_field_value'] = { :value => user.email, :expires => 10.years.from_now, :domain => request.domain } unless user.is_openid?
    end
    flash[:good] = "Вы успешно подтвердили свой емейл, #{user.username}!"

    if current_user
      if was_confirmed
        redirect_to :action => 'email'
      else
        redirect_to settings_url(:host => host_for_tlog(current_user))
      end
    else
      # перенаправляем пользователя в настройки его тлога
      session[:redirect_to] = settings_url(:host => host_for_tlog(current_user)) unless was_confirmed
      redirect_to login_url
    end
  end

  private
    def redirect_home_if_current_user_is_confirmed
      redirect_to settings_url(:host => host_for_tlog(current_user)) and return false if current_user.is_confirmed?
      true
    end
end