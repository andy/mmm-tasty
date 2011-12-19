# какой пользователь как голосовал
class CreateEntryVotes < ActiveRecord::Migration
  def self.up
    create_table :entry_votes do |t|
      t.column :entry_id, :integer, :null => false
      t.column :user_id, :integer, :null => false       # пользователь которому принадлежит запись
      t.column :value, :integer, :null => false, :default => 0        # числовой рейтинг
    end

    add_index :entry_votes, [:entry_id, :user_id], :unique => true
  end

  def self.down
    drop_table :entry_votes
  end
end