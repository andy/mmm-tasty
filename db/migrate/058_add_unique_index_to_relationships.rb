class AddUniqueIndexToRelationships < ActiveRecord::Migration
  def self.up
    add_index :relationships, [:user_id, :reader_id], :unique => true
  end

  def self.down
    remove_index :relationships, [:user_id, :reader_id]
  end
end
