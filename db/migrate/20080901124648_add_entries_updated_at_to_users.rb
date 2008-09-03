class AddEntriesUpdatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :entries_updated_at, :datetime
    User.update_all "users.entries_updated_at = '#{Time.now.to_s(:db)}'"
  end

  def self.down
    remove_column :users, :entries_updated_at
  end
end