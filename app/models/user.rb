class User < ActiveRecord::Base
  RESERVED = %w( mmm-tasty mobile rest blog blogs www support help ftp http ed2k smtp pop pop3 adm mail admin test password restore backup sys system dev account register signup web wwww ww w mmm info ad archive status logs log guest debug demo podcast info tools guide preview svn example google yandex rambler goog googl goggle gugl )
  SIGNATURE_SECRET = 'kab00mmm, tasty!'
  EMAIL_SIGNATURE_SECRET = 'YO SHALL NOT KNOW EVER!@@@#!'

  attr_accessor :password
  attr_accessible :openid, :email, :url, :password, :entries_updated_at

	has_many :entries, :dependent => :destroy
	has_one :avatar, :dependent => :destroy
  has_one :tlog_settings, :dependent => :destroy
  has_one :tlog_design_settings, :dependent => :destroy
  has_one :mobile_settings, :dependent => :destroy

  has_many :sidebar_sections, :dependent => :destroy
  has_many :bookmarklets, :dependent => :destroy
  has_one :feedback, :dependent => :destroy
  has_many :messages, :dependent => :destroy
  has_many :faves, :dependent => :destroy

  after_destroy do |user|
    # удяляем relationships
    user.connection.delete("DELETE FROM relationships WHERE user_id = #{user.id} OR reader_id = #{user.id}")
    # удаляем все подписки
    user.connection.delete("DELETE FROM entry_subscribers WHERE user_id = #{user.id}")
  end

  def signature
    Digest::SHA1.digest([self.id, self.is_openid? ? self.openid : self.email, self.created_at.to_s, SIGNATURE_SECRET].pack('LZ*Z*Z*'))
  end

  def recover_secret
    Digest::SHA1.hexdigest([self.id, self.email, self.crypted_password, self.created_at.to_s, SIGNATURE_SECRET].pack('LZ*Z*Z*Z*'))
  end

	validates_presence_of :url, :on => :save, :message => "это обязательное поле"

	validates_uniqueness_of :email, :if => Proc.new { |u| !u.email.blank? }, :message => 'пользователь с таким емейлом уже зарегистрирован', :case_sensitive => false
	validates_uniqueness_of :openid, :if => Proc.new { |u| !u.openid.blank? }, :message => 'пользователь с таким openid уже зарегистрирован', :case_sensitive => false
	validates_uniqueness_of :url, :message => 'к сожалению, этот адрес уже занят', :case_sensitive => false

	validates_format_of :openid, :with => Format::HTTP_LINK, :if => Proc.new { |u| !u.openid.blank? }, :message => 'не похоже на openid'
  validates_format_of :email, :with => Format::EMAIL, :if => Proc.new { |u| !u.email.blank? }, :message => 'не похоже на емейл или openid'
  validates_length_of :url, :within => 1..20, :too_long => 'адрес не может быть более 20и символов'
  validates_format_of :url, :with => /^[a-z0-9]([a-z0-9\-]{1,20})?$/i, :message => 'адрес содержит недопустимые символы. пожалуйста, выберите другой'
  validates_exclusion_of :url, :in => RESERVED, :message => 'к сожалению, этот адрес уже занят'
  validates_length_of :password, :within => 5..20, :if => Proc.new { |u| !u.password.blank? }, :too_short => 'пароль слишком короткий, минимум 5 символов'
  validates_format_of :domain, :with => Format::DOMAIN, :if => Proc.new { |u| !u.domain.blank? }, :on => :save, :message => 'не похоже на домен'

	serialize :settings
	before_save :encrypt_password
	before_create :set_default_settings
  after_create do |user|
    user.tlog_settings = TlogSettings.create :user => user
    user.tlog_design_settings = TlogDesignSettings.create :user => user
    # добавляем новости автоматически
    news = User.find_by_url('news')
    Relationship.create :user => news, :reader => user, :position => 0, :last_viewed_entries_count => news.entries_count_for(user), :last_viewed_at => Time.now, :friendship_status => Relationship::DEFAULT
  end

  def validate
    if openid.blank? && email.blank?
      errors.add(:email, 'укажите, пожалуйста, адрес')
    end

    if openid.blank? && !email.blank? && password.nil? && crypted_password.blank?
      errors.add(:password, 'необходимо выбрать пароль')
    end
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end


	# при авторизации по паролю нужно использовать эту функцию, потому
	#  что позже может быть добавлен механизм криптования паролей
	def self.authenticate(email, password)
	  return nil if email.empty?
	  user = User.find_by_email(email) || User.find_by_openid(email)

	  # если пользователь не был найден по openid, попробуем добавить или убрать слеш в конце
	  #  http://anonuzer.myopenid.com -> http://anonuzer.myopenid.com/
	  if user.nil? && email.is_openid?
	    user = User.find_by_openid(email.ends_with?('/') ? email.chop : email + '/')
	  end

    # пользователь должен существовать и не должен быть заблокирован
	  return nil if user.nil? or user.is_disabled?

	  # он может быть либо openid и тогда пароль не проверяется, либо обычным, но тогда
	  #  мы требуем чтобы пароль совпадал
	  return user if user.is_openid? || (user.crypted_password == encrypt(password, user.salt) && !user.crypted_password.blank?)

	  # иначе - до свидания
	  nil
  end

  def self.popular(limit = 6)
    user_ids = Rails.cache.fetch('Users.popular', :expires_in => 1.day) { User.find_by_sql("SELECT user_id AS id,count(*) AS c FROM relationships WHERE friendship_status > 0 GROUP BY user_id ORDER BY c DESC LIMIT 100") }
    User.find_all_by_id(user_ids.map(&:id).shuffle[0...limit], :include => [:avatar, :tlog_settings])
  end

  def is_openid?
    !self.openid.blank?
  end

  # количество записей для пользователя user. либо entries_count, либо public_entries_count
  def entries_count_for(user = nil)
    (user && self.id == user.id) ? self.entries_count : self.public_entries_count
  end

  # количество публичных записей (т.е. видимых всем)
  def public_entries_count
    self.entries_count - self.private_entries_count
  end

  # время когда была написана последняя запись
  def last_public_entry_at
    # self.entries.public.last.created_at - the same?
    Entry.find_by_sql("SELECT id, created_at FROM entries WHERE user_id = #{self.id} AND is_private = 0 ORDER BY entries.id DESC LIMIT 1").first.created_at rescue Time.now
  end

  # User.find(1).calendar.each do |day, entries|
  def calendar(date=nil)
    date ||= Date.today
    time = date.to_time
    start_at = time.since(1.month).at_end_of_month
    end_at = time.ago(1.month).at_beginning_of_month

    Rails.cache.fetch("calendar_#{self.id}_#{self.entries_count}_#{start_at.to_i}_#{end_at.to_i}", :expires_in => 1.day) do
      calendar = Entry.find_by_sql(['SELECT id, created_at, DATE_FORMAT(created_at, "%d-%m-%y") day, count(*) as count FROM entries WHERE user_id = ? AND is_private = 0 AND created_at < ? AND created_at > ? GROUP BY day ORDER BY created_at ASC', self.id, start_at.to_s(:db), end_at.to_s(:db)])
      calendar.group_by { |entry| entry.created_at.month }.sort_by { |a| a }
    end
  end

  # возвращает список текущих записей для пользователя, возможные параметры:
  #   page - текущая страница
  #   page_size - количество записей на странице
  #   include_private - включать ли закрытые записи
  #   only_private - только скрытые записи
  def recent_entries(options = {})
    options[:page]        = 1 if !options.has_key?(:page) || options[:page] <= 0
    options[:page_size]   = Entry::PAGE_SIZE if !options.has_key?(:page_size) || options[:page_size] <= 0
    include_private       = options[:include_private] || false
    only_private          = options[:only_private] || false
    include_private     ||= true if only_private

    e_count               = only_private ? self.private_entries_count : (include_private ? self.entries_count : self.public_entries_count)
    e_count               = 0 if e_count < 0

    conditions = []
    conditions << 'entries.is_private = 0' unless include_private
    conditions << 'entries.is_private = 1' if only_private
    conditions << "entries.created_at BETWEEN '#{options[:time].strftime("%Y-%m-%d")}' AND '#{options[:time].tomorrow.strftime("%Y-%m-%d")}'" if options[:time]
    conditions = conditions.blank? ? nil : conditions.join(' AND ')

    find_options = { :order => 'entries.id DESC', :include => [:author, :attachments, :rating], :conditions => conditions }
    find_options[:page] = { :current => options[:page], :size => options[:page_size], :count => e_count } unless options[:time]

    entries.find(:all, find_options)
  end

  # ID последних записей ПЛЮС количество комментариев с количеством просмотров для пользователя user
  def recent_entries_with_views_for(user=nil, options = {})
    page            = (options[:page] || 1).to_i
    include_private = options[:include_private] || false

    conditions_sql = " WHERE e.user_id = #{self.id}"
    conditions_sql += " AND e.is_private = 0" unless include_private
    if user
      entries.find_by_sql("SELECT e.id,e.comments_count,v.last_comment_viewed FROM entries e LEFT JOIN comment_views AS v ON v.entry_id = e.id AND v.user_id = #{user.id} #{conditions_sql} ORDER BY e.id DESC LIMIT #{(page > 0 ? (page - 1) : 0)  * Entry::PAGE_SIZE}, #{Entry::PAGE_SIZE}")
    else
      entries.find_by_sql("SELECT id,comments_count FROM entries e #{conditions_sql} ORDER BY e.id DESC LIMIT #{(page > 0 ? (page - 1) : 0)  * Entry::PAGE_SIZE}, #{Entry::PAGE_SIZE}")
    end
  end

  def recent_entries_with_ratings(options = {})
    page            = (options[:page] || 1).to_i
    include_private = options[:include_private] || false

    conditions_sql = " WHERE e.user_id = #{self.id}"
    conditions_sql += " AND e.is_private = 0" unless include_private
    entries.find_by_sql("SELECT e.id,r.value FROM entries AS e LEFT JOIN entry_ratings AS r ON r.entry_id = e.id AND r.user_id = #{self.id} #{conditions_sql} ORDER BY e.id DESC LIMIT #{(page > 0 ? (page - 1) : 0)  * Entry::PAGE_SIZE}, #{Entry::PAGE_SIZE}")
  end

  def can_create?(klass)
    return true if self.is_premium?
    if klass.to_s == 'SongEntry'
      return false if klass.count(:conditions => "user_id = #{self.id} AND created_at > CURDATE()") > 0 # не более одной в день
    end
    true
  end

  def confirmation_code_for(email)
    Digest::SHA1.hexdigest("- #{email} - #{EMAIL_SIGNATURE_SECRET} -")[0..8]
  end

  def update_confirmation!(email=nil)
    email ||= self.email
    self.settings_will_change!
    self.settings[:email_confirmation_code] = [ email, self.confirmation_code_for(email) ]
    self.update_attribute(:settings, self.settings) unless self.new_record?
  end

  def read_confirmation_code
    "#{self.id}_#{self.settings[:email_confirmation_code][1]}"
  end

  def read_confirmation_email
    self.settings[:email_confirmation_code][0] rescue nil
  end

  def clear_confirmation
    self.settings_will_change!
    self.settings.delete(:email_confirmation_code)
  end

  # возвращает либо новый емейл, либо nil
  def validate_confirmation(code)
    code = code.split(/_/)[1] if code =~ /^\d+_[a-f0-9]{7,33}$/i # убираем префикс с ID
    valid_email, valid_code = self.settings[:email_confirmation_code]
    return valid_email if valid_code == code
    # всегда проверяем основной емейл
    return self.email if !self.email.blank? && self.confirmation_code_for(self.email) == code
    nil
  end

  def is_admin?
    [1, 2].include?(self.id)
  end

  # пользователь выключен, анонимен, либо имеет неподтвержденный емейл адрес
  def is_limited?
    self.is_disabled? || (!self.is_openid? && !self.is_confirmed?)
  end

  # можно ли пользователю отправлять письма?
  def is_emailable?
    self.is_confirmed? && !self.email.blank?
  end

  # может ли вообще голосовать за эту запись?
  def can_vote?(entry)
    return false if self.is_limited?
    return false if entry.user_id == self.id
    true
  end

  # сила голоса пользователя. Пока что абсолютно равоне для всех
  def vote_power
    1
  end

  # выставляем пользователю ключ (и создаем новый если его не было еще)
  def last_personalized_key
    self.settings[:last_personalized_key] ||= begin
      key = String.random
      self.settings_will_change!
      self.settings[:last_personalized_key] = key
      self.save
      key
    end
  end

  private
    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{url}--")
      self.crypted_password = encrypt(password)
    end

    def set_default_settings
      begin
  	    self.settings ||= Hash.new
  	  rescue ActiveRecord::SerializationTypeMismatch
  	    self.settings = Hash.new
      end
  	  true
    end
end


module UserModelExtensions
  module Relationships
    USER_AND_RELATIONSHIP_COLUMNS = 'u.*,r.title,r.friendship_status,r.read_count,r.comment_count,r.position,r.last_viewed_entries_count,r.last_viewed_at,r.id AS relationship_id'

    def self.included(base)
      base.has_many :relationships, :dependent => :destroy

      # лишь хорошие друзья
      {
        :public_friends => { :filter => '= 2', :order => 'r.position' },
        :friends => { :filter => '= 1', :order => 'r.position' },
        :guessed_friends => { :filter => '= 0 AND r.read_count > 4', :order => 'r.read_count DESC' },
        :all_friends => { :filter => '> 0', :order => 'r.friendship_status DESC, r.position' },
        :everybody => { :filter => nil, :order => nil }
      }.each do |name, params|
        param_filter = params[:filter] ? " AND r.friendship_status #{params[:filter]}" : ''
        param_order = params[:order] ? " ORDER BY #{params[:order]}" : ''

        base.has_many name.to_sym, :class_name => 'User', :finder_sql => "SELECT #{USER_AND_RELATIONSHIP_COLUMNS} FROM relationships AS r LEFT JOIN users AS u ON u.id = r.user_id WHERE r.reader_id = \#{id} #{param_filter} #{param_order}"
        # e.g. public_friend_r (- relationship model)
        base.has_many "#{name.to_s.singularize}_r".to_sym, :class_name => 'Relationship', :finder_sql => "SELECT r.* FROM relationships AS r WHERE r.reader_id = \#{id} #{param_filter}"
        # e.g. listed_me_as_public_friend (which means - get me my readers that have me listed as public friend)
        base.has_many "listed_me_as_#{name.to_s.singularize}".to_sym, :class_name => 'User', :finder_sql => "SELECT #{USER_AND_RELATIONSHIP_COLUMNS} FROM relationships AS r LEFT JOIN users AS u ON u.id = r.reader_id WHERE r.user_id = \#{id} #{param_filter} #{param_order}"
        # same as previous, but only a relationship model which is much lighter as it fetches only from relationships table and does not include User
        base.has_many "listed_me_as_#{name.to_s.singularize}_r".to_sym, :class_name => 'Relationship', :finder_sql => "SELECT r.* FROM relationships AS r WHERE r.user_id = \#{id} #{param_filter}"
      end

      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      # Пользователь user читает текущего пользователя
      def reads(user)
        return if self.id == user.id

        relationship = relationship_with(user, true)
        do_save = relationship.new_record?
        relationship.friendship_status = Relationship::GUESSED if relationship.new_record?

        # абсолютных друзей не бывает, engeen
        if relationship.read_count < 20 && (!relationship.last_read_at || relationship.last_read_at < Math.exp(relationship.read_count).ago)
          relationship.increment(:read_count)
          relationship.last_read_at = Time.now
          do_save = true
        end

        relationship.save! if do_save
        relationship
      end

      def relationship_with(user, create = false)
        return false if self.id == user.id
        relationship = create ? \
          Relationship.find_or_initialize_by_user_id_and_reader_id(user.id, self.id) : \
          Relationship.find_by_user_id_and_reader_id(user.id, self.id)
        relationship.position = 0 if relationship && relationship.new_record?
        relationship
      end

      # то же самое что и relationship_with, но возвращает объект User с
      #  дополнительными полями из relationships
      def relationship_as_user_with(user)
        return if self.id == user.id
        result = User.find_by_sql "SELECT #{USER_AND_RELATIONSHIP_COLUMNS} FROM relationships AS r LEFT JOIN users AS u ON u.id = r.user_id WHERE r.user_id = #{user.id} AND r.reader_id = #{self.id} LIMIT 1"
        result[0] if result
      end

      def set_friendship_status_for(user, to = Relationship::DEFAULT)
        relationship = relationship_with(user, true)
        relationship.update_attributes!({ :friendship_status => to }) if relationship && relationship.friendship_status != to
        relationship
      end

      # Подписан ли на ленту пользоваетля user? Возвращает true / false
      def subscribed_to?(user)
        return false unless user
        (relationship = relationship_with(user)) && relationship.friendship_status >= Relationship::DEFAULT
      end

      # Пользователь user комментирует записи другого пользователя
      def comments(user)
        return if self.id == user.id
        relationship = Relationship.find_or_initialize_by_user_id_and_reader_id(user.id, self.id)
        relationship.increment(:comment_count)
        relationship.last_comment_at = Time.now
        relationship.save!
      end
    end
  end

  module Settings
    def self.included(base)
      base.extend UserModelExtensions::Settings::ClassMethods
      base.send(:include, UserModelExtensions::Settings::InstanceMethods)
    end

    module ClassMethods
    end

    module InstanceMethods
      # Пример: <%= user.gender("он", "она") %>
      def gender(he = nil, she = nil)
        gender = read_attribute(:gender)
        (he && she) ? (gender.to_s == 'f' ? she : he) : gender
      end

      def username
        @username ||= read_attribute(:username).blank? ? self.url : read_attribute(:username)
      end
    end
  end

  module Tags
    def self.included(base)
      base.send(:include, UserModelExtensions::Tags::InstanceMethods)
    end

    module InstanceMethods
      #
      # the following code comes from markaboo
      #
      DEFAULT_CATEGORY_OPTIONS = {:include_private => false, :max_rows => 10}.freeze
      DEFAULT_FIND_OPTIONS = {:owner => nil, :include_private => false}.freeze

      # Get the tags for a user
      def tags(include_private=false)
        Tag.find_all_by_user(self, include_private)
      end

      def tag_count
        sql = <<-GO
        SELECT DISTINCT tags.id
        FROM users
        INNER JOIN entries
        on users.id = entries.user_id
        INNER JOIN taggings
        ON entries.id = taggings.taggable_id and 'Entry' = taggings.taggable_type
        INNER JOIN tags
        ON taggings.tag_id = tags.id
        WHERE users.id = #{self.id}

        GO
        result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
        result.num_rows
      end

      # Returns the N most frequent categories for this user (N defaults to 10)
      def top_categories(options={})
        options = DEFAULT_CATEGORY_OPTIONS.merge(options)

        sql = <<-GO
        SELECT tags.name, COUNT(*) number
        FROM users
        INNER JOIN entries
        ON users.id = entries.user_id
        INNER JOIN taggings
        ON entries.id = taggings.taggable_id and 'Entry' = taggings.taggable_type
        INNER JOIN tags
        ON taggings.tag_id = tags.id
        WHERE users.id = #{self.id}
        #{' AND entries.is_private = 0 ' unless options[:include_private] == true}
        GROUP BY tags.name
        ORDER BY number DESC, tags.name ASC
        #{"limit %d " % options[:max_rows] unless options[:max_rows] == 0}
        GO

        result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
        tags = []
        result.each {|row| tags << [row[0], row[1].to_i]}
        tags
      end

      def find_tagged_with(tags, options={})
        options = DEFAULT_FIND_OPTIONS.merge(options)
        sql = <<-GO
          SELECT entries.*
          FROM entries
          INNER JOIN taggings
          ON entries.id = taggings.taggable_id and 'Entry' = taggings.taggable_type
          INNER JOIN tags
          ON taggings.tag_id = tags.id
          WHERE  #{'entries.is_private = 0 and' unless options[:include_private]}
          entries.user_id = #{self.id} and tags.name IN (#{tags.to_query})
        GO
        result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
        result.fetch_row[0].to_i
      end

      def count_tagged_with(tags, options={})
        options = DEFAULT_FIND_OPTIONS.merge(options)
        sql = <<-GO
          SELECT count(distinct entries.id) count_all
          FROM entries
          INNER JOIN taggings
          ON entries.id = taggings.taggable_id and 'Entry' = taggings.taggable_type
          INNER JOIN tags
          ON taggings.tag_id = tags.id
          WHERE  #{'entries.is_private = 0 and' unless options[:include_private]}
          entries.user_id = #{self.id} and tags.name IN (#{tags.to_query})
        GO
        result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
        result.fetch_row[0].to_i
      end

      def tag_cloud(options = {})
        options[:max_rows] = 50 unless options[:max_rows]
        Tag.cloud { self.top_categories(options) }
      end
    end
  end
end

User.send(:include, UserModelExtensions::Tags)
User.send(:include, UserModelExtensions::Settings)
User.send(:include, UserModelExtensions::Relationships)