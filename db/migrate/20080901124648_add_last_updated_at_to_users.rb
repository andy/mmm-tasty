class AddLastUpdatedAtToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :entries_updated_at, :datetime
  end

  def self.down
    remove_column :users, :entries_updated_at
  end
end
