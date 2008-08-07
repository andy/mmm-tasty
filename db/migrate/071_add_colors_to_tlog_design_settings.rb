class AddColorsToTlogDesignSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_design_settings, :color_bg, :string, :limit => 6
    add_column :tlog_design_settings, :color_tlog_text, :string, :limit => 6
    add_column :tlog_design_settings, :color_tlog_bg, :string, :limit => 6
    add_column :tlog_design_settings, :color_sidebar_text, :string, :limit => 6
    add_column :tlog_design_settings, :color_sidebar_bg, :string, :limit => 6
  end

  def self.down
    remove_column :tlog_design_settings, :color_bg
    remove_column :tlog_design_settings, :color_tlog_text
    remove_column :tlog_design_settings, :color_tlog_bg
    remove_column :tlog_design_settings, :color_sidebar_text
    remove_column :tlog_design_settings, :color_sidebar_bg
  end
end
