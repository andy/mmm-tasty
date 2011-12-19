class AddIsMainpageableToEntries < ActiveRecord::Migration
  def self.up
    remove_column :entries, :is_mainageable
    add_column :entries, :is_mainpageable, :boolean, { :default => true, :null => false }
    add_index :entries, [:is_mainpageable, :created_at, :type]
    add_index :entries, [:user_id, :is_private, :created_at]
  end

  def self.down
    add_column :entries, :is_mainageable, :boolean, { :default => true, :null => false }
    remove_column :entries, :is_mainpageable
    remove_index :entries, [:is_mainpageable, :created_at, :type]
    remove_index :entries, [:user_id, :is_private, :created_at]
  end
end

