class AddIndexesToCommentViews < ActiveRecord::Migration
  def self.up
    add_index :comment_views, [:entry_id, :user_id], :unique => true
  end

  def self.down
    remove_index :comment_views, [:entry_id, :user_id]
  end
end