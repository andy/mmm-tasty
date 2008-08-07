class AddTastyNewsletterToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :tasty_newsletter, :boolean, { :null => false, :default => true }
  end

  def self.down
    remove_column :tlog_settings, :tasty_newsletter
  end
end
