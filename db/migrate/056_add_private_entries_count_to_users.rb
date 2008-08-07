class AddPrivateEntriesCountToUsers < ActiveRecord::Migration
  def self.up
    # мы считаем именно _скрытые_ записи потому что их будет предположительно меньше, а значит обновлений будет меньше тоже
    add_column :users, :private_entries_count, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :users, :private_entries_count
  end
end
