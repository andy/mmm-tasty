class AddEmailCommentsToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :email_comments, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :tlog_settings, :email_comments
  end
end
