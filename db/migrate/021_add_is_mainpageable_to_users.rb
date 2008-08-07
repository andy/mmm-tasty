class AddIsMainpageableToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_mainpageable, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :users, :is_mainpageable
  end
end
