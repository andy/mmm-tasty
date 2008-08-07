class CreateFriends < ActiveRecord::Migration
  def self.up
		create_table :user_friends do |t|
			t.column :user_id, :integer, { :null => false }
			t.column :friend_id, :integer, { :null => false }
		end
  end

  def self.down
		drop_table :user_friends
  end
end
