class AddUpdatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :updated_at, :timestamp
    remove_column :users, :modified_at
  end

  def self.down
    add_column :users, :modified_at, :timestamp
    remove_column :users, :updated_at
  end
end
