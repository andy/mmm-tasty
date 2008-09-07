class AddPastDisabledToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :past_disabled, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :tlog_settings, :past_disabled
  end
end
