class CreateEntryRatings < ActiveRecord::Migration
  def self.up
    create_table :entry_ratings do |t|
      t.column :entry_id, :integer, :null => false
      t.column :entry_type, :string, :limit => 20, :null => false
      t.column :created_at, :timestamp, :null => false
      t.column :user_id, :integer, :null => false       # пользователь которому принадлежит запись
      t.column :value, :integer, :null => false, :default => 0        # числовой рейтинг
    end

    add_index :entry_ratings, [:value, :entry_type]
    add_index :entry_ratings, :entry_id, :unique => true
  end

  def self.down
    drop_table :entry_ratings
  end
end