class AddIsIgnoredToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :is_ignored, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :relationships, :is_ignored
  end
end
