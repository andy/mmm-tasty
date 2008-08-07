class AddLastEntriesCountToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :last_viewed_at, :timestamp
    add_column :relationships, :last_viewed_entries_count, :integer, :null => false, :default => 0
    Relationship.update_all "last_viewed_at = now()"
  end

  def self.down
    remove_column :relationships, :last_viewed_at
    remove_column :relationships, :last_viewed_entries_count
  end
end
