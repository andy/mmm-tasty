class Message < ActiveRecord::Base
  belongs_to :user, :counter_cache => true # пользователь которому было отправлено сообщение
  belongs_to :sender, :class_name => 'User', :foreign_key => 'sender_id' # кто написал сообщение

  attr_accessible :body, :is_private

  # находит записи видимые определенному пользователю. дополнительно к обычным параметрам find
  #  требуются так же:
  #   :user => current_user
  #   :site => current_site
  def self.find_for_user(options)
    site = options.delete(:site)
    user = options.delete(:user)

    conditions = ["user_id = #{site.id}"]
    if !user
      conditions << "is_private = 0"
    elsif site.id != user.id
      conditions << "(is_private = 0 OR sender_id = #{user.id})"
    end

    options[:conditions] = conditions.join(' AND ')
    options[:order] = 'messages.id DESC'
    find(:all, options)
  end

  # является ли пользователь владельцем сообщения?
  # владельцев может быть несколько и ими являются:
  # 1 - пользователь который оставил запись
  # 2 - пользователь которому запись принадлежит, т.е. в чьем тлоге она была размещена
  def is_owner?(user)
    return false unless user
    user.id == self.sender_id || user.id == self.user_id
  end
end