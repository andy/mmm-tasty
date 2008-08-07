class Feedback < ActiveRecord::Base
  belongs_to :user
  
  def self.random(options = {})
    options[:order] = 'RAND()'
    find :all, options
  end
  
  def is_owner?(user)
    user && user.id == self.user_id
  end
end
