class Feedback < ActiveRecord::Base
  belongs_to :user
  
  # отзывы, ожидающие модерации
  named_scope :pending, :conditions => { :is_moderated => false }
  
  def publish!
    self.update_attributes(:is_public => true, :is_moderated => true)
  end
  
  def discard!
    self.update_attributes(:is_public => false, :is_moderated => true)
  end
  
  def self.random(options = {})
    options[:order] = 'RAND()'
    find :all, options
  end
  
  def is_owner?(user)
    user && user.id == self.user_id
  end
end
