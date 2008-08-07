class AddUserIdToAttachment < ActiveRecord::Migration
  def self.up
    add_column :attachments, :user_id, :integer, :null => false
  end

  def self.down
    remove_column :attachments, :user_id
  end
end
