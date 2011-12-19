class MoveCommentsEnabledToTlogSettings < ActiveRecord::Migration
  def self.up
    # добавляем поле с количеством комментариев
    add_column :tlog_settings, :comments_enabled, :boolean, :default => false, :null => true

    # мигрируем запись из user.settings в tlog_settings..
    User.find(:all, :include => [:tlog_settings]).each do |user|
      comments_enabled = user.settings[:comments_enabled] rescue false
      user.tlog_settings.update_attribute(:comments_enabled, comments_enabled)
      user.update_attributes!({ :settings => user.settings }) if user.settings.delete(:comments_enabled)
    end
  end

  def self.down
    # мигрируем из tlog_settings в settings...
    User.find(:all, :include => [:tlog_settings]).each do |user|
      user.settings[:comments_enabled] = user.tlog_settings.comments_enabled?
      user.save!
    end
    # удаляем
    remove_column :tlog_settings, :comments_enabled
  end
end
