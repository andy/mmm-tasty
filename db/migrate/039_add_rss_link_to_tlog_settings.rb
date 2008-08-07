class AddRssLinkToTlogSettings < ActiveRecord::Migration
  def self.up
    add_column :tlog_settings, :rss_link, :string
  end

  def self.down
    remove_column :tlog_settings, :rss_link
  end
end
