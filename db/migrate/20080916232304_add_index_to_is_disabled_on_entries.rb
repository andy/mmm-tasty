class AddIndexToIsDisabledOnEntries < ActiveRecord::Migration
  def self.up
    add_index :entries, [:is_disabled]
  end

  def self.down
    remove_index :entries, [:is_disabled]
  end
end
