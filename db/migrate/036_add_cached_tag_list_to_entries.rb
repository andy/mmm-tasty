class AddCachedTagListToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :cached_tag_list, :text
  end

  def self.down
    remove_column :entries, :cached_tag_list
  end
end
