class AddCounters < ActiveRecord::Migration
  def self.up
    add_column :users, :entries_count, :integer, { :default => 0, :null => false }
    User.find(:all).each { |user| user.update_attribute(:entries_count, user.entries.count) }

    add_column :entries, :comments_count, :integer, { :default => 0, :null => false }
    Entry.find(:all).each { |entry| entry.update_attribute(:comments_count, entry.comments.count) }
  end

  def self.down
    remove_column :users, :entries_count
    remove_column :entries, :comments_count
  end
end
