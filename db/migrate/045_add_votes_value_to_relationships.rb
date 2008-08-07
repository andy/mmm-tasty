class AddVotesValueToRelationships < ActiveRecord::Migration
  def self.up
    add_column :relationships, :votes_value, :integer, { :null => false, :default => 0 }
    add_index :relationships, [:reader_id, :votes_value]
  end

  def self.down
    remove_index :relationships, [:reader_id, :votes_value]
    remove_column :relationships, :votes_value
  end
end
