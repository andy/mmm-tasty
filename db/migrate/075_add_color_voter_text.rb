class AddColorVoterText < ActiveRecord::Migration
  def self.up
    add_column :tlog_design_settings, :color_voter_text, :string, :limit => 6
    add_column :tlog_design_settings, :background_fixed, :boolean, :null => false, :default => 0
    add_column :tlog_design_settings, :color_tlog_bg_is_transparent, :boolean, :null => false, :default => 0
    add_column :tlog_design_settings, :color_sidebar_bg_is_transparent, :boolean, :null => false, :default => 0
    add_column :tlog_design_settings, :color_voter_bg_is_transparent, :boolean, :null => false, :default => 0
  end

  def self.down
    remove_column :tlog_design_settings, :color_voter_text
    remove_column :tlog_design_settings, :background_fixed
    remove_column :tlog_design_settings, :color_tlog_bg_is_transparent
    remove_column :tlog_design_settings, :color_sidebar_bg_is_transparent
    remove_column :tlog_design_settings, :color_voter_bg_is_transparent
  end
end