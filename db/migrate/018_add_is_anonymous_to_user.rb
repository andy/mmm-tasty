class AddIsAnonymousToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_anonymous, :boolean, { :null => false, :default => false }
    execute 'update users set is_anonymous = 1 where url like "%-anonymous"'
  end

  def self.down
    remove_column :users, :is_anonymous
  end
end
