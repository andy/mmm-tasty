class UpdateRelationshipsToReflectModelChanges < ActiveRecord::Migration
  def self.up
    # было: автоматические друзья - 0, осталось 0
    # было: публичные друзья - 1, стало - 2
    # появились дрзуья которых читаешь, они не автоматические (1)
    # игнорируемых пока что оставляем в -1

    Relationship.update_all('friendship_status = 2', 'friendship_status = 1')
    Relationship.update_all('friendship_status = 1', 'friendship_status = 0 AND read_count > 6')
  end

  def self.down
    Relationship.update_all('friendship_status = 0', 'friendship_status = 1')
    Relationship.update_all('friendship_status = 1', 'friendship_status = 2')
  end
end
