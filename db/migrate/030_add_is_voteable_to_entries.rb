class AddIsVoteableToEntries < ActiveRecord::Migration
  def self.up
    add_column :entries, :is_voteable, :boolean, :default => false
  end

  def self.down
    remove_column :entries, :is_voteable
  end
end