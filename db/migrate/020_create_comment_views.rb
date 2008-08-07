class CreateCommentViews < ActiveRecord::Migration
  def self.up
    create_table :comment_views do |t|
        t.column :entry_id, :integer, :null => false
        t.column :user_id, :integer, :null => false
        t.column :last_comment_viewed, :integer, :null => false
    end
  end

  def self.down
    drop_table :comment_views
  end
end
