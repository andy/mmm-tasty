class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.column :entry_id, :integer, { :null => false }
      t.column :comment, :text

      # если локальный пользователь оставил комментарий
      t.column :user_id, :integer, { :default => 0, :null => true }

      # если незарегистрированный
      t.column :ext_username, :string, { :null => true }
      t.column :ext_url, :string, { :null => true }

      # закрытый / удаленный комменатрий
      t.column :is_disabled, :boolean, { :default => false, :null => false }

      t.column :created_at, :timestamp, { :null => false }
    end

    add_index :comments, [:entry_id, :user_id]
  end

  def self.down
  end
end
