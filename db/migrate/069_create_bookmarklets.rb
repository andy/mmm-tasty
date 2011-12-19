class CreateBookmarklets < ActiveRecord::Migration
  def self.up
    create_table :bookmarklets do |t|
      t.column :user_id, :integer, :null => false
      t.column :created_at, :datetime, :null => false
      t.column :name, :string, :null => false
      t.column :entry_type, :string, :null => false, :limit => 16, :default => 'text'
      t.column :tags, :text
      t.column :visibility, :string, :null => false, :limit => 16, :default => 'private'
      t.column :autosave, :boolean, :null => false, :default => 0
      t.column :is_public, :boolean, :null => false, :default => 0
    end

    add_index :bookmarklets, [:user_id, :created_at]
    add_index :bookmarklets, [:is_public, :created_at]
  end

  def self.down
    drop_table :bookmarklets
  end
end
