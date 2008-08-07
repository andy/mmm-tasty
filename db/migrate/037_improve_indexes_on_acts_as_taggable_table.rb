class ImproveIndexesOnActsAsTaggableTable < ActiveRecord::Migration
  def self.up
    remove_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, [:taggable_id, :taggable_type, :tag_id], :unique => true
  end

  def self.down
    remove_index :taggings, [:taggable_id, :taggable_type, :tag_id]
    add_index :taggings, [:taggable_id, :taggable_type]
  end
end
