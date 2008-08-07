class RenameIsIgnoredToFriendshipStatusInRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :friendship_status, :integer, :default => 0, :null => false
    remove_column :relationships, :is_ignored
  end

  def self.down
    # we would really loose way too much if we migrate it backwards
    raise IrreversibleMigration
  end
end
