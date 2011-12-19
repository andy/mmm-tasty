class MoveUserSettingsToModel < ActiveRecord::Migration
  def self.up
    add_column :users, :email_comments, :boolean, :null => false, :default => true
    add_column :users, :comments_auto_subscribe, :boolean, :null => false, :default => true
    add_column :users, :gender, :string, :limit => 1, :null => false, :default => 'm'
    add_column :users, :username, :string

    User.find(:all).each do |user|
      User.transaction do
        if user.settings
          user.gender = user.settings.delete(:gender) || user[:gender]
          user.username = user.settings.delete(:username) || user.username
        end
        user.email_comments = user.tlog_settings.email_comments?
        user.comments_auto_subscribe = true
        user.save!
      end
    end

    remove_column :tlog_settings, :email_comments
  end

  def self.down
    raise IrreversibleMigration
  end
end
