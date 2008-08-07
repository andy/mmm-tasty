class AddRemoteIpToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :remote_ip, :string, :limit => 17
  end

  def self.down
    remove_column :comments, :remote_ip
  end
end
