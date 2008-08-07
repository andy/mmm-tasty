class AddMetadataToEntry < ActiveRecord::Migration
  def self.up
    add_column :entries, :metadata, :text, :null => true
  end

  def self.down
    remove_column :entries, :metadata
  end
end
