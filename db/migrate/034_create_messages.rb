class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.column :user_id, :integer, { :null => false }
      t.column :sender_id, :integer, { :null => false }
      t.column :body, :text, { :null => false }
      t.column :body_html, :text, { :null => false }

      # закрытый / удаленный комменатрий
      t.column :is_private, :boolean, { :default => false, :null => false }
      t.column :is_disabled, :boolean, { :default => false, :null => false }

      t.column :created_at, :timestamp, { :null => false }
      t.column :updated_at, :timestamp
    end

    add_index :messages, [:user_id]
  end

  def self.down
    drop_table :messages
  end
end