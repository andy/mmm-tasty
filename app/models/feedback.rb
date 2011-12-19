class Feedback < ActiveRecord::Base
  belongs_to :user

  # отзывы, ожидающие модерации
  named_scope :pending, :conditions => { :is_moderated => false }
  named_scope :published, :conditions => { :is_public => true }
  named_scope :random, :order => 'RAND()'

  def publish!
    self.update_attributes(:is_public => true, :is_moderated => true)
  end

  def discard!
    self.update_attributes(:is_public => false, :is_moderated => true)
  end

  def is_owner?(user)
    user && user.id == self.user_id
  end
end
