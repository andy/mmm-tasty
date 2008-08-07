class AddUserIdIndexToTlogSettings < ActiveRecord::Migration
  def self.up
    add_index :tlog_settings, [:user_id]
  end

  def self.down
    remove_index :tlog_settings, [:user_id]
  end
end
