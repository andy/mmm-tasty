class UpdatePerformances < ActiveRecord::Migration
  def self.up
    rename_column :performances, :seconds, :realtime
    add_column :performances, :stime, :float, :null => false, :default => 0.0
    add_column :performances, :utime, :float, :null => false, :default => 0.0
    add_column :performances, :cstime, :float, :null => false, :default => 0.0
    add_column :performances, :cutime, :float, :null => false, :default => 0.0
  end

  def self.down
    drop_column :performances, :stime
    drop_column :performances, :utime
    drop_column :performances, :cstime
    drop_column :performances, :cutime
    rename_column :performances, :realtime, :seconds
  end
end
