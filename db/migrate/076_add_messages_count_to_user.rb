class AddMessagesCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :messages_count, :integer, { :default => 0, :null => false }
  end

  def self.down
    remove_column :users, :messages_count
  end
end