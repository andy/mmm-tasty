class AddSidebarIsOpenToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :sidebar_is_open, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :tlog_settings, :sidebar_is_open
  end
end
