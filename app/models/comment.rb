class Comment < ActiveRecord::Base
  belongs_to :entry, :counter_cache => :comments_count
  belongs_to :user

  attr_accessible :comment, :ext_username, :ext_url

  # internal validations
  validates_presence_of :entry_id
  # validates_associated :entry
  validates_presence_of :user_id, :if => Proc.new { |c| c.ext_username.blank? }

  # ext_username - имя пользователя. Обязательное поле если пользователь неавторизован
  validates_presence_of :ext_username, :if => Proc.new { |c| c.user_id == 0 }
  validates_length_of :ext_username, :within => 1..40, :if => Proc.new { |c| c.user_id == 0 }

  # ext_url - необязательное поле, которое должно содержать урл адрес
  validates_format_of :ext_url, :with => /^(http|https):\/\/.*$/i, :if => Proc.new { |c| !c.ext_url.blank? }
  validates_length_of :ext_url, :within => 6..300, :if => Proc.new { |c| !c.ext_url.blank? }

  # comment - обязательное поле для всех
  validates_presence_of :comment, :on => :create, :message => "куда ж без комментария!"
  validates_length_of :comment, :within => 1..2000

  after_destroy do |comment|
    # обновляем счетчик просмотренных комментариев но только для тех, кто уже видел комментарий который сейчас был удален
    comment.connection.update("UPDATE comment_views SET last_comment_viewed = last_comment_viewed - 1 WHERE entry_id = #{comment.entry.id} AND last_comment_viewed > #{comment.entry.comments.size - 1}")
    comment.entry.update_attribute(:updated_at, Time.now)
  end

  after_create do |comment|
    comment.entry.update_attribute(:updated_at, Time.now)
  end

  @loaded_from_cookie = false

  #
  # <%= comment.store_preprocessed_comment { |text| white_list_anonymous_comment text }
  def fetch_cached_or_run_block(&block)
    return self.comment_html unless self.comment_html.blank?
    self.comment_html = block.call self.comment
    self.save unless self.new_record?

    self.comment_html
  end

  # сохраняет параметры комментария
  def request=(request)
    self.remote_ip = request.remote_ip
  end

  # Может ли пользователь %user удалять этот комментарий?
  #  можно передать entry, которая должна быть той же записью что и self.entry, но при обращении к self.entry
  #  вызывается лишний SQL запрос, и этого можно избежать, передав entry вторым аргументом
  def is_owner?(user, entry=nil)
    entry ||= self.entry
    user && (user.id == self.user_id || user.id == entry.user_id)
  end

  # Упаковывает комментарий чтобы его можно было сохранить в куку:
  #   cookies['comment_identity'] = { :value => @comment.pack_for_cookie, :expires => 10.years.from_now, :domain => request.domain }
  def pack_for_cookie
    # pack two as a zero-string, then encode with base64 (m)
    [self.ext_username, self.ext_url].pack('Z*Z*').to_a.pack('m').chop
  end

  def loaded_from_cookie
    @loaded_from_cookie
  end

  # Распаковывам параметры комментария из куки
  #   comment = Comment.new_from_cookie()
  def self.new_from_cookie(value)
    comment = self.new
    comment.ext_username, comment.ext_url = value.unpack('m').first.unpack('Z*Z*')

    unless comment.valid?
      comment.ext_username = nil if comment.errors.on :ext_username
      comment.ext_url = nil if comment.errors.on :ext_url
      comment.errors.clear
    end

    comment.loaded_from_cookie = true
    comment
  end
end
