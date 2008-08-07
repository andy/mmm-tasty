class AddUpdatedAtToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :updated_at, :timestamp
    remove_column :entries, :modified_at
  end

  def self.down
    add_column :entries, :modified_at, :timestamp
    remove_column :entries, :updated_at
  end
end
