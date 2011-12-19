class Fave < ActiveRecord::Base
  belongs_to :user, :counter_cache => true
  belongs_to :entry

  def is_owner?(user)
    user.id == self.user_id
  end
end