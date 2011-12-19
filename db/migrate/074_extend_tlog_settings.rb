class ExtendTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :is_daylog, :boolean, :default => 0, :null => false
    add_column :tlog_settings, :sidebar_hide_tags, :boolean, :default => 1, :null => false
    add_column :tlog_settings, :sidebar_hide_calendar, :boolean, :default => 0, :null => false
    add_column :tlog_settings, :sidebar_hide_search, :boolean, :default => 0, :null => false
  end

  def self.down
    remove_column :tlog_settings, :is_daylog
    remove_column :tlog_settings, :sidebar_hide_tags
    remove_column :tlog_settings, :sidebar_hide_calendar
    remove_column :tlog_settings, :sidebar_hide_search
  end
end