class CreateRelationships < ActiveRecord::Migration
  def self.up
    create_table :relationships do |t|
      t.column :user_id, :integer, { :null => false }
      t.column :reader_id, :integer, { :null => false }

      # acts_as_list
      t.column :position, :integer

      t.column :read_count, :integer, { :null => false, :default => 0 }
      t.column :last_read_at, :timestamp

      t.column :comment_count, :integer, { :null => false, :default => 0 }
      t.column :last_comment_at, :timestamp
    end

    add_index :relationships, [:user_id, :reader_id, :position]
    add_index :relationships, [:reader_id, :user_id, :position]
  end

  def self.down
    drop_table :relationships
  end
end
