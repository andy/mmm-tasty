class AddMainpageableAndPrivateToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :is_mainageable, :boolean, { :default => true, :null => false }
    add_column :entries, :is_private, :boolean, { :default => false, :null => false }
  end

  def self.down
    remove_column :entries, :is_mainageable
    remove_column :entries, :is_private
  end
end