class AddMessagesToTlogSettings < ActiveRecord::Migration
  def self.up
    # убрать ли раздел личных сообщений в боковой панели?
    add_column :tlog_settings, :sidebar_hide_messages, :boolean, { :default => false, :null => false }
    # название для "сообщений"
    add_column :tlog_settings, :sidebar_messages_title, :string
    # отправлять ли личные сообщения по почте?
    add_column :tlog_settings, :email_messages, :boolean, { :default => true, :null => false }
  end

  def self.down
    remove_column :tlog_settings, :sidebar_hide_messages
    remove_column :tlog_settings, :sidebar_messages_title
    remove_column :tlog_settings, :email_messages
  end
end