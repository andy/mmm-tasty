class CommentViews < ActiveRecord::Base
  belongs_to :entry
  belongs_to :user

  validates_presence_of :entry_id
  validates_presence_of :user_id
  validates_presence_of :last_comment_viewed

  class << self
    # Пользователь user просмотрел запись entry
    def view(entry, user)
      if entry.comments.size
        cv = CommentViews.find_or_initialize_by_entry_id_and_user_id(entry.id, user.id)
        last_comment_viewed = cv.last_comment_viewed
        if cv.last_comment_viewed != entry.comments.size
          cv.last_comment_viewed = entry.comments.size
          cv.save
        end
        last_comment_viewed
      else
        0
      end
    end
  end
end