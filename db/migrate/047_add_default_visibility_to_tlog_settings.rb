class AddDefaultVisibilityToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :default_visibility, :string, :default => 'mainpageable', :null => false
  end

  def self.down
    remove_column :tlog_settings, :default_visibility
  end
end
