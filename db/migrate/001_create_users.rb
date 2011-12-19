class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      # Два механизма авторизации:
      # 1) email/password
  			t.column :email, :string, { :null => true }
  			t.column :is_confirmed, :boolean, { :default => false, :null => false }
  			t.column :password, :string, { :null => true }
      # 2) openid
			  t.column :openid, :string, { :null => true }

      t.column :url, :string, { :null => false }

			t.column :settings, :text

			# системные настройки
			t.column :is_disabled, :boolean, { :default => false, :null => false }
			t.column :created_at, :timestamp, { :null => false }
			t.column :modified_at, :timestamp
    end

    add_index :users, :email, :uniq => true
    add_index :users, :openid, :uniq => true
    add_index :users, :url, :uniq => true
  end

  def self.down
    drop_table :users
  end
end
