class AddOptimizationIndexToRelationships < ActiveRecord::Migration
  def self.up
    add_index :relationships, [:reader_id, :friendship_status]
  end

  def self.down
    remove_index :relationships, [:reader_id, :friendship_status]
  end
end
