# это голос одного пользователя
class EntryVote < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user

  validates_presence_of :user_id
  validates_presence_of :entry_id
end