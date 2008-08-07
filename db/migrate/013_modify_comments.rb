class ModifyComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :updated_at, :timestamp
    add_column :comments, :comment_html, :text
  end

  def self.down
    remove_column :comments, :updated_at
    remove_column :comments, :comment_html
  end
end
