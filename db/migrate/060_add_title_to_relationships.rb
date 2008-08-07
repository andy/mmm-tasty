class AddTitleToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :title, :string, :limit => 128
  end

  def self.down
    remove_column :relationships, :title
  end
end
