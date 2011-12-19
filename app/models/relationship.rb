class Relationship < ActiveRecord::Base
  # есть пользователь :user которого читает другой пользователь, :reader
  belongs_to :user
  belongs_to :reader, :class_name => 'User', :foreign_key => 'reader_id'

  validates_presence_of :user_id
  validates_presence_of :reader_id
  validates_inclusion_of :friendship_status, :in => -1..2

  acts_as_list :scope => 'reader_id = #{reader_id} AND friendship_status = #{friendship_status}'

  PUBLIC = 2
  DEFAULT = 1
  GUESSED = 0
  IGNORED = -1

  def say_it(user, reader)
    case friendship_status
    when PUBLIC
      user.gender('Он у тебя в друзьях', 'Она у тебя в друзьях')
    when DEFAULT
      reader.gender("Ты подписан на #{user.gender('его', 'её')} тлог", "Ты подписана на #{user.gender('его', 'её')} тлог")
    else
      "Подписаться на #{user.gender('его', 'её')} тлог"
    end
  end
end