class CreateEntrySubscribers < ActiveRecord::Migration
  # для habtm
  def self.up
    create_table :entry_subscribers, :id => false do |t|
      t.column :entry_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end

    add_index :entry_subscribers, [:entry_id, :user_id], :unique => true
  end

  def self.down
    remove_table :entry_subscribers
  end
end