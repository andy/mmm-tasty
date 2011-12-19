class EmailConfirmationMailer < ActionMailer::Base
  helper :application, :comments

  def signup(user)
    @subject    = 'ммм... регистрация'
    @body       = {:user => user}
    @recipients = user.email
    @from       = '"Ммм... тейсти" <noreply@mmm-tasty.ru>'
    @sent_on    = Time.now
    @headers    = {}
  end

  def confirm(user, email)
    @subject    = 'ммм... подтверждение емейл адреса'
    @body       = {:user => user, :email => email}
    @recipients = email
    @from       = '"Mmm... noreply" <noreply@mmm-tasty.ru>'
    @sent_on    = Time.now
    @headers    = {}
  end

  def message(user, message)
    @subject    = 'ммм.... новое личное сообщение'
    @body       = { :user => user, :message => message }
    @recipients = user.email
    @from       = '"Mmm... message" <messages@mmm-tasty.ru>'
    @send_on    = Time.now
    @headers    = {}
  end

  def comment(user, comment)
    @subject    = "ммм... комментарий (#{comment.entry.excerpt})"
    @body       = {:comment => comment}
    @recipients = user.email
    @from       = '"Mmm... comments" <comments@mmm-tasty.ru>'
    @sent_on    = Time.now
    @headers    = {}
  end

  def comment_reply(user, comment)
    @subject    = "ммм... ответ на Ваш комментарий (#{comment.entry.excerpt})"
    @body       = {:user => user, :comment => comment}
    @recipients = user.email
    @from       = '"Mmm... comments" <comments@mmm-tasty.ru>'
    @sent_on    = Time.now
    @headers    = {}
  end

  # письмо для пользователей подписанных на комментарии
  def comment_to_subscriber(user, comment)
    @subject    = "ммм... комментарий (#{comment.entry.excerpt})"
    @body       = {:user => user, :comment => comment}
    @recipients = user.email
    @from       = '"Mmm... comments" <comments@mmm-tasty.ru>'
    @sent_on    = Time.now
    @headers    = {}
  end

  # письмо-напоминание о забытом пароле
  def lost_password(user)
    @subject    = 'ммм... напоминание пароля'
    @body       = {:user => user, :recover_link => recover_password_url(:host => 'www.mmm-tasty.ru', :user_id => user.id, :secret => user.recover_secret) }
    @recipients = user.email
    @from       = '"Mmm... password" <noreply@mmm-tasty.ru>'
    @sent_on    = Time.now
    @headers    = {}
  end
end