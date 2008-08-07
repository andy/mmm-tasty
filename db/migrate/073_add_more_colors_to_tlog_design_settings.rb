class AddMoreColorsToTlogDesignSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_design_settings, :color_link, :string, :limit => 6
    add_column :tlog_design_settings, :color_highlight, :string, :limit => 6
    add_column :tlog_design_settings, :color_date, :string, :limit => 6
    add_column :tlog_design_settings, :color_voter_bg, :string, :limit => 6
  end

  def self.down
    remove_column :tlog_design_settings, :color_link
    remove_column :tlog_design_settings, :color_highlight
    remove_column :tlog_design_settings, :color_date
    remove_column :tlog_design_settings, :color_voter_bg
  end
end
