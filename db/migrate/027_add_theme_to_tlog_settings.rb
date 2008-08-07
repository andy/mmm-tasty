class AddThemeToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :theme, :string, :null => true
  end

  def self.down
    remove_column :tlog_settings, :theme
  end
end
