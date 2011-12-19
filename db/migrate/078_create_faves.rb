class CreateFaves < ActiveRecord::Migration
  def self.up
    create_table :faves do |t|
      t.column :user_id, :integer, :null => false
      t.column :entry_id, :integer, :null => false
      t.column :entry_type, :string, { :null => false, :limit => 64 }
      t.column :entry_user_id, :integer, :null => false
      t.column :created_at, :datetime
    end

    # количество сохраненных закладок у текущего пользователя
    add_column :users, :faves_count, :integer, { :null => false, :default => 0 }

    # закладки текущего пользователя
    add_index :faves, [:user_id, :entry_id], :unique => true
    # мои закладки у текущего пользователя
    add_index :faves, [:user_id, :entry_user_id]
    # закладки определенного типа
    add_index :faves, [:user_id, :entry_type]
  end

  def self.down
    drop_table :faves
    remove_column :users, :faves_count
  end
end