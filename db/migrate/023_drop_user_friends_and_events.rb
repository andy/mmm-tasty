class DropUserFriendsAndEvents < ActiveRecord::Migration
  def self.up
    drop_table :user_friends
    drop_table :events
  end

  def self.down
    # wasn't used anyways
  end
end
