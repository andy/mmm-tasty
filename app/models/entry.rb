class Entry < ActiveRecord::Base
	belongs_to :author, :class_name => 'User', :foreign_key => 'user_id', :counter_cache => true
	has_many :comments, :dependent => :destroy, :order => 'comments.id'
	has_many :comment_views, :class_name => 'CommentViews', :dependent => :destroy
	has_many :attachments, :dependent => :destroy
	has_one :rating, :class_name => 'EntryRating', :dependent => :destroy
	has_many :votes, :class_name => 'EntryVote', :dependent => :destroy
	has_many :faves, :dependent => :destroy
  has_and_belongs_to_many :subscribers, :class_name => 'User', :join_table => 'entry_subscribers'
  # has_one :ad, :class_name => 'SocialAd', :dependent => :destroy

  named_scope :anonymous, :conditions => { :type => 'AnonymousEntry' }
  named_scope :for_view, :include => [:author, :attachments, :rating], :order => 'entries.id DESC'
  named_scope :private, :conditions => 'entries.is_private = 1 AND entries.type != "AnonymousEntry"'

  after_destroy do |entry|
    # удаляем всех подписчиков этой записи
    entry.subscribers.clear
    # уменьшаем счетчик скрытых записей, если эта запись - скрытая
    User.decrement_counter(:private_entries_count, entry.user_id) if entry.is_private?
    # уменьшаем количество просмотренных записей для всех пользователей которые подписаны на ленту, но только если это
    #  была видимая запись И если она не входила в число _новых_ записей для пользователя который просматривает. Поэтому, как
    #  критерий мы испльзуем поле last_viewed_at для того чтобы определить входила ли запись в число новых
    Relationship.update_all "last_viewed_entries_count = last_viewed_entries_count - 1", "user_id = #{entry.user_id} AND last_viewed_entries_count > 0 AND last_viewed_at > '#{entry.created_at.to_s(:db)}'" unless entry.is_private?

    # обновляем таймстамп который используется для инвалидации кеша тлоговых страниц, но только в том случае
    #  если меняются штуки отличные от комментариев
    entry.author.update_attributes(:entries_updated_at => Time.now) unless (entry.changes.keys - ['comments_count', 'updated_at']).blank?
  end

  after_create do |entry|
    # счетчик скрытых записей. нам так удобнее делать постраничную навигацию
    User.increment_counter(:private_entries_count, entry.user_id) if entry.is_private?
  end

  after_save do |entry|
    # обновляем таймстамп который используется для инвалидации кеша тлоговых страниц, но только в том случае
    #  если меняются штуки отличные от комментариев
    entry.author.update_attributes(:entries_updated_at => Time.now) unless (entry.changes.keys - ['comments_count', 'updated_at']).blank?
  end


	acts_as_sphinx
	acts_as_taggable

	attr_accessible :data_part_1, :data_part_2, :data_part_3
	serialize :metadata
	cattr_accessor :has_attachment

	validates_presence_of :author

	ENTRY_MAX_LENGTH = 10.kilobytes
	ENTRY_MAX_LINK_LENGTH = 2.kilobytes
	PAGE_SIZE = 15

  KINDS = {
    :any => { :select => 'все записи', :singular => 'спросить при добавлении', :filter => '1=1', :order => 1 },
    :text => { :select => 'текстовые', :singular => 'текст', :filter => 'entry_type = "TextEntry"', :order => 2 },
    :link => { :select => 'ссылки', :singular => 'ссылка', :filter => 'entry_type = "LinkEntry"', :order => 3 },
    :quote => { :select => 'цитаты', :singular => 'цитата', :filter => 'entry_type = "QuoteEntry"', :order => 4 },
    :image => { :select => 'картинки', :singular => 'картинка', :filter => 'entry_type = "ImageEntry"', :order => 5 },
    :video => { :select => 'видео', :singular => 'видео', :filter => 'entry_type = "VideoEntry"', :order => 6 },
    :convo => { :select => 'диалоги', :singular => 'диалог', :filter => 'entry_type = "ConvoEntry"', :order => 7 },
    :song => { :select => 'песни', :singular => 'песня', :filter => 'entry_type = "SongEntry"', :order => 8 },
    :code => { :select => 'программные коды', :singular => 'программный код', :filter => 'entry_type = "CodeEntry"', :order => 9 }
    # :anonymous => { :select => 'анонимные записи', :singular => 'анонимка', :filter => 'entry_type = "AnonymousEntry"', :order => 10 }
  }
  KINDS_FOR_SELECT = KINDS.sort_by { |obj| obj[1][:order] }.map { |k,v| [v[:select], k.to_s] }
  KINDS_FOR_SELECT_SIGNULAR = KINDS.sort_by { |obj| obj[1][:order] }.map { |k,v| [v[:singular], k.to_s] }

  # видимость записи, @entry.visibility - это виртуальное поле, options: 0 - is_voteable, 1 - is_mainpageable, 2 - is_private
  VISIBILITY = {
    :private => { :new => 'закрытая - не увидит никто, кроме вас', :edit => 'закрытая - не увидит никто, кроме вас', :options => [false, false, true], :order => 1 },
    :public => { :new => 'открытая - видна всем только в вашем тлоге', :edit => 'открытая - видна всем только в вашем тлоге', :options => [false, false, false], :order => 2 },
    :mainpageable => { :new => 'публичная - видна всем и попадает в прямой эфир', :edit => 'публичная - видна всем и попадает в прямой эфир', :options => [false, true, false], :order => 3 },
    :voteable => { :new => 'публичная с голосованием', :edit => 'публичная с голосованием', :options => [true, true, false], :order => 4 }
  }
  VISIBILITY_FOR_SELECT_NEW = VISIBILITY.sort_by { |obj| obj[1][:order] }.map { |k,v| [v[:new], k.to_s] }
  VISIBILITY_FOR_SELECT_EDIT = VISIBILITY.sort_by { |obj| obj[1][:order] }.map { |k,v| [v[:edit], k.to_s] }

	# Виртуальный атрибут visibility позволяет нам заботиться о всех составляющих видимости записи практически через одну функцию
  def visibility
    VISIBILITY.find { |v| v[1][:options] == [self.is_voteable?, self.is_mainpageable?, self.is_private?] }[0].to_s
  end

  def visibility=(kind)
    options = VISIBILITY[kind.to_sym][:options]

    # если is_voteable стоит в true - ничего нельзя имзенить...
    if !self.is_voteable? || self.new_record?
      self.is_voteable, self.is_mainpageable, self.is_private = options
      # 0 - is_voteable, выставляется только если пользователю разрешено это делать и только на новую запись
      self.is_voteable = true if options[0] && self.new_record?
    end
  end

  # Могут ли у этой записи быть аттачи? По умолчанию аттачменты отключены
  def can_have_attachments?; false end

  # Анонимная запись или нет?
  def is_anonymous?
    self[:type] == 'AnonymousEntry'
  end

  def can_delete?(user)
    user && user.id == self.user_id
  end

  # Жуткий мезанизм определения на какой странице находится запись
  def page_for(user = nil, zero_if_last = true, options = {})
    is_daylog = options.delete(:is_daylog) || false
    if self.new_record?
      zero_if_last ? 0 : self.author.entries_count_for(user).to_pages
    else
      conditions = "id >= #{self.id}"
      conditions += " AND user_id = #{self.user_id}"
      conditions += if self.is_anonymous?
          " AND type = 'AnonymousEntry'"
        elsif self.is_private?
          " AND is_private = 1 AND type != 'AnonymousEntry'"
        else
          " AND is_private = 0"
        end
      # conditions += " AND is_private = 0" unless (user && user.id == self.user_id)
      entry_offset = Entry.count(:conditions => conditions)
      total_pages = self.author.entries_count_for(user).to_pages
      entry_page = ((entry_offset / Entry::PAGE_SIZE.to_f).floor + 1).reverse_page(total_pages)
      (zero_if_last && entry_page == total_pages) ? 0 : entry_page
    end
  end

  def next(options = {})
    include_private = options.fetch(:include_private, false)
    @next ||= Entry.find_by_sql("SELECT id, created_at, user_id, comments_count, updated_at, is_voteable, is_private, is_mainpageable, comments_enabled FROM entries WHERE id > #{self.id} AND user_id = #{self.user_id}#{' AND is_private = 0 ' unless include_private} LIMIT 1").first rescue nil
  end

  def prev(options = {})
    include_private = options.fetch(:include_private, false)
    @prev ||= Entry.find_by_sql("SELECT id, created_at, user_id, comments_count, updated_at, is_voteable, is_private, is_mainpageable, comments_enabled FROM entries WHERE id < #{self.id} AND user_id = #{self.user_id}#{' AND is_private = 0 ' unless include_private} ORDER BY id DESC LIMIT 1").first rescue nil
  end

  def next_id
    @next_id ||= Entry.find_by_sql("SELECT id FROM entries WHERE id > #{self.id} AND user_id = #{self.user_id} AND is_private = 0 LIMIT 1").first[:id] rescue false
  end

  def prev_id
    @prev_id ||= Entry.find_by_sql("SELECT id FROM entries WHERE id < #{self.id} AND user_id = #{self.user_id} AND is_private = 0 ORDER BY id DESC LIMIT 1").first[:id] rescue false
  end

  def self.new_from_bm(params)
    self.new :data_part_2 => params[:url], :data_part_1 => params[:c], :data_part_3 => params[:title]
  end

  def to_russian(key=:who)
    entry_russian_dict[key]
  end

  def vote(user, rating)
    return unless user.can_vote?(self)

    # находим существующую запись
    EntryRating.transaction do
      entry_rating = EntryRating.find_by_entry_id(self.id) or return

      # голос пользователя: нам его нужно либо создать, либо использвовать уже имющийся
      user_vote = EntryVote.find_or_initialize_by_entry_id_and_user_id(self.id, user.id)
      # новая запись или пользователь поменял свое мнение?
      if user_vote.new_record? || (rating * user.vote_power) != user_vote.value
        # вычитаем старое значение если пользователь поменял свое мнение
        entry_rating.value -= user_vote.value unless user_vote.new_record?
        user_vote.value = rating * user.vote_power
        entry_rating.value += user_vote.value

        # сохраняем новое в базу
        user_vote.save && entry_rating.save
      end
    end
  end

  def voted?(user)
    EntryVote.find_by_entry_id_and_user_id(self.id, user.id).value rescue 0
  end

  # в чем глубокий смысл этого кода?
  def make_voteable(enable=true)
    entry_rating = EntryRating.find_or_initialize_by_entry_id(self.id)
    if enable
      # создаем, при этом восстанавливаем рейтинг у записи - оставляем тот который был
      entry_rating.attributes = { :entry_id => self.id, :entry_type => self.attributes['type'], :value => self.votes.sum(:value) || 0, :user_id => self.user_id } if entry_rating.new_record?
      self.rating = entry_rating
    else
      self.rating = nil
    end
  end

  def comments_grouped_by_authors
    self.comments.group_by { |comment| comment.ext_username || comment.user_id }
  end


  #
  # Code below goes from markaboo
  #   код для вычисления тегов для текущей записи и для тегов вообще
  #
  DEFAULT_CATEGORY_OPTIONS = {:include_private => false, :max_rows => 10}.freeze
  DEFAULT_FIND_OPTIONS = {:owner => nil, :include_private => false}.freeze
  DEFAULT_PAGE_OPTIONS = {:page => 1, :total => 0, :limit => PAGE_SIZE}.freeze
  # Used to find a page of bookmarks in a given category/categories either for everyone
  # or a specific user
  def self.paginate_by_category(categories, page_options, find_options={})
    find_options = DEFAULT_FIND_OPTIONS.merge(find_options)
    page_options = DEFAULT_PAGE_OPTIONS.merge(page_options)
    offset = (page_options[:page] - 1) * page_options[:limit]

    conditions = "tags.name IN (#{categories.map(&:sql_quote)})"
    conditions += " AND entries.user_id = #{find_options[:owner].id}" if find_options[:owner]
    conditions += ' AND entries.is_private = 0' unless find_options[:include_private]


    sql = <<-GO
      SELECT entries.id
      FROM tags INNER JOIN taggings ON tags.id = taggings.tag_id INNER JOIN entries ON entries.id = taggings.taggable_id
      WHERE #{conditions}
      ORDER BY entries.id DESC LIMIT #{offset}, #{page_options[:limit]}
    GO

    entry_ids = Tag.find_by_sql(sql)
    entry_ids = entry_ids.collect!(&:id)

    records = find(entry_ids, :order => 'entries.id DESC', :include => [:author])
    class << records; self end.send(:define_method, :total) {page_options[:total].to_i}
    class << records; self end.send(:define_method, :limit) {page_options[:limit].to_i}
    class << records; self end.send(:define_method, :offset) {offset}
    records.extend Paginator
    records
  end

  # Returns the N most frequent categories (N defaults to 10)
  def self.top_categories(options={})
    options = DEFAULT_CATEGORY_OPTIONS.merge(options)

    conditions = []
    conditions << "entries.user_id = #{options[:owner].id}" if options[:owner]
    conditions << 'entries.is_private = 0' unless options[:include_private]

    sql = <<-GO
    SELECT name, COUNT(*) number
    FROM tags
    INNER JOIN taggings
    ON tags.id = taggings.tag_id
    INNER JOIN entries
    ON taggings.taggable_id = entries.id
    INNER JOIN users
    ON entries.user_id = users.id
    #{" WHERE %s " % conditions.join(' AND ') unless conditions.blank?}
    GROUP BY name
    ORDER BY number DESC, name ASC
    #{"limit %d " % options[:max_rows] unless options[:max_rows] == -1}
    GO
    result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
    tags = []
    result.each {|row| tags << [row[0], row[1].to_i]}
    tags
  end

  # Use a better-performing query to count the resources associated with a particular tag
  def self.count_tagged_with(tags, options={})
    options = DEFAULT_FIND_OPTIONS.merge(options)

    conditions = []
    conditions << "tags.name IN (#{tags.map(&:sql_quote)})"
    conditions << 'entries.is_private = 0' unless options[:include_private]
    conditions << "entries.user_id = #{options[:owner].id}" if options[:owner]

    sql = <<-GO
      SELECT count(distinct entries.id) count_all
      FROM entries
      INNER JOIN taggings
      ON entries.id = taggings.taggable_id AND 'Entry' = taggings.taggable_type
      INNER JOIN tags
      ON taggings.tag_id = tags.id
      WHERE #{conditions.join(' AND ')}
    GO

    result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
    result.fetch_row[0].to_i
  end


  before_validation :reset_data_parts_if_blank
  before_create :set_default_metadata

  protected
    # выставляем значение в NULL чтобы не было пустышек в базе
    def reset_data_parts_if_blank
      self.data_part_1 = nil if self.data_part_1.blank?
      self.data_part_2 = nil if self.data_part_2.blank?
      self.data_part_3 = nil if self.data_part_3.blank?
      true
    end

    # добавляет префикс http:// к ссылке если она вообще похожа на ссылку
    def make_a_link_from_data_part_1_if_present
      self.data_part_1 = make_a_link_from_data(self.data_part_1)
      true
    end

    # добавляет префикс http:// к ссылке если она вообще похожа на ссылку
    def make_a_link_from_data_part_3_if_present
      self.data_part_3 = make_a_link_from_data(self.data_part_3)
      true
    end

    def no_attachment
      !self.has_attachment
    end

  private
    # делает ссылку из строки. это нужно в нескольких моделях сразу, где пользователь может ввести ссылку на
    # какой-нибудь адрес при этом не указав http:// в начале. Чтобы потом не возиться - возимся сразу
    def make_a_link_from_data(data)
      return data if data.blank?
      return data if data.strip =~ Format::LINK
      data = 'http://' + data.strip if data.strip.split(/(:|\/)/)[0] =~ Format::DOMAIN
      data
    end

    def set_default_metadata
      begin
  	    self.metadata ||= {}
  	  rescue ActiveRecord::SerializationTypeMismatch
  	    self.metadata = {}
      end
  	  true
    end
end


#
# Текстовая запись
#   data_part_1 - текст
#   data_part_2 - заголовок
class TextEntry < Entry
  validates_presence_of :data_part_1, :on => :save
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LENGTH, :on => :save, :too_long => 'это поле слишком длинное'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :on => :save, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'

  def entry_russian_dict; { :who => 'ммм... пост', :whom => 'ммм... пост' } end
  def excerpt
    if self.data_part_2.to_s.length > 0
      self.data_part_2.to_s.truncate(150).to_s
    else
      self.data_part_1.to_s.truncate(150).to_s
    end
  end
  def self.new_from_bm(params)
    content = params[:c].strip if params[:c]
    content ||= ''
    title = params[:title].strip if params[:title]
    # разбиваем на две новые части если нет заголовка, но есть содержимое
    title, content = content.split("\n", 2) if title.blank? && !content.blank?
    title = title.truncate(50) if title
    content += "\n<a href='#{params[:url]}'>отсюда</a>" if content
    self.new :data_part_1 => content, :data_part_2 => title
  end
end


#
# Анонимная текстовая запись
#   data_part_1 - текст
#   data_part_2 - заголовок
class AnonymousEntry < Entry
  validates_presence_of :data_part_1, :on => :save
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LENGTH, :on => :save, :too_long => 'это поле слишком длинное'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :on => :save, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'

  def entry_russian_dict; { :who => 'анонимка', :whom => 'анонимку' } end
  def excerpt
    if self.data_part_2.to_s.length > 0
      self.data_part_2.to_s.truncate(150).to_s
    else
      self.data_part_1.to_s.truncate(150).to_s
    end
  end
  def self.new_from_bm(params)
    content = params[:c].strip if params[:c]
    content ||= ''
    title = params[:title].strip if params[:title]
    # разбиваем на две новые части если нет заголовка, но есть содержимое
    title, content = content.split("\n", 2) if title.blank? && !content.blank?
    title = title.truncate(50) if title
    content += "\n<a href='#{params[:url]}'>отсюда</a>" if content
    self.new :data_part_1 => content, :data_part_2 => title
  end
end


#
# Цитата
#   data_part_1 - текст цитаты (обяз)
#   data_part_2 - автор / источник
class QuoteEntry < Entry
  validates_presence_of :data_part_1, :on => :save
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LENGTH, :on => :save, :too_long => 'это поле слишком длинное'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :on => :save, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'

  def entry_russian_dict; { :who => 'цитата', :whom => 'цитату' } end
  def excerpt
    self.data_part_1.to_s.truncate(150).to_s
  end
  def self.new_from_bm(params)
    self.new :data_part_1 => params[:c], :data_part_2 => "<a href='#{params[:url]}'>#{params[:title] || params[:url]}</a>"
  end
end


#
# Cсылка куда-либо
#   data_part_1 - адрес ссылки (обяз)
#   data_part_2 - заголовок для ссылки
#   data_part_3 - дополнительное описание
class LinkEntry < Entry
  validates_presence_of :data_part_1, :on => :save, :message => 'это обязательное поле'
  validates_format_of :data_part_1, :with => Format::LINK, :message => 'неопознанный формат ссылки'
  validates_length_of :data_part_1, :within => 0..ENTRY_MAX_LINK_LENGTH, :too_long => 'ссылка какая-то очень длинная'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'
  validates_length_of :data_part_3, :within => 0..ENTRY_MAX_LENGTH, :if => Proc.new { |e| !e.data_part_3.blank? }, :too_long => 'это поле слишком длинное'

  def entry_russian_dict; { :who => 'ссылка', :whom => 'ссылку' } end
  def excerpt
    if self.data_part_2.to_s.length > 0
      self.data_part_2.to_s.truncate(150).to_s
    elsif self.data_part_3.to_s.length > 0
      self.data_part_3.to_s.truncate(150).to_s
    else
      'Ссылка'
    end
  end

  def self.new_from_bm(params)
    self.new :data_part_1 => params[:url], :data_part_2 => params[:title], :data_part_3 => params[:c]
  end

  before_validation :make_a_link_from_data_part_1_if_present
end


#
# Залитая фотография либо ссылка на фото
#   data_part_1 - ссылка, если нет аттачмента
#   data_part_2 - описание
#   data_part_3 - ссылка под фотографией
class ImageEntry < Entry
  validates_presence_of :data_part_1, :on => :save, :if => :no_attachment, :message => 'это обязательное поле'
  validates_format_of :data_part_1, :with => Format::HTTP_LINK, :if => :no_attachment, :message => 'ссылка должна быть на веб-сайт, т.е. начинаться с http://'
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LINK_LENGTH, :if => :no_attachment, :too_long => 'ссылка какая-то очень длинная'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'
  validates_length_of :data_part_3, :within => 0..ENTRY_MAX_LINK_LENGTH, :if => Proc.new { |e| !e.data_part_3.blank? }, :too_long => 'ссылка какая-то очень длинная'
  validates_format_of :data_part_3, :with => Format::HTTP_LINK, :if => Proc.new { |e| !e.data_part_3.blank? }, :message => 'ссылка должна быть на веб-сайт, т.е. начинаться с http://'

  def entry_russian_dict; { :who => 'картинка', :whom => 'картинку' } end
  def can_have_attachments?; true end

  before_validation :make_a_link_from_data_part_1_if_present
  def excerpt
    if self.data_part_2.to_s.length > 0
      self.data_part_2.to_s.truncate(150).to_s
    else
      'Картинка'
    end
  end

  def self.new_from_bm(params)
    url = params[:url]
    uri = URI.parse(url)
    source = url if uri.path && %w(.jpg .jpeg .gif .png .bmp).include?(File.extname(uri.path.downcase))
    content = params[:c]
    # если фликер - спец обработчик
    if uri.host && uri.path && uri.host.ends_with?('flickr.com')

      # согласно http://www.flickr.com/services/api/misc.urls.html
      photo_id = if uri.host.ends_with?('.static.flickr.com')
                  # статический путь до картинки - http://farm1.static.flickr.com/81/248825450_1140cb041a.jpg?v=0
                  uri.path.match(/^\/[0-9]*\/([0-9]*)/i)[1]
                elsif uri.host == 'www.flickr.com' && uri.path =~ /^\/photos\/[^\/]*\/([0-9]*)/i
                  # дали путь до html файла с картинкой, photo_id = $1
                  # http://www.flickr.com/photos/caballero/248825450/in/photostream/
                  $1
                end
      if photo_id
        require 'flickr'

        photo = Flickr::Photo.new photo_id
        source = photo.source
        url = photo.url
        content ||= ["<b>#{photo.title}</b>", photo.description].join("\n")
      end
    end
    self.new :data_part_1 => source, :data_part_2 => content, :data_part_3 => url
  end


  def data_part_1=(link)
    write_attribute(:data_part_1, link)

    if link =~ Format::HTTP_LINK
      self.metadata_will_change!
      self.metadata = {} if self.metadata.nil?
      self.metadata.merge!(get_metadata_for_linked_image(link))
    end
  end

  # функция вычисления симметричных размеров для текущей картинки. работает как для записей
  # с локальной картинкой, так и для записей только со ссылкой на картинку.
  def geometry(options = {})
    width = options[:width] || 420
    height = options[:height] || 0
    image = options[:image]
    image ||= self.attachments.first if self.attachments

    if image
      image_width, image_height = self.attachments.first.width, self.attachments.first.height
    elsif self.metadata && self.metadata.has_key?(:width)
      image_width, image_height = self.metadata[:width], self.metadata[:height]
    else
      return { }
    end

    w_ratio = width > 0 ? width.to_f / image_width.to_f : 1
    h_ratio = height > 0 ? height.to_f / image_height.to_f : 1

    ratio = [w_ratio, h_ratio].min

    # пересчитываем
    width = ratio < 1 ? (image_width * ratio).to_i : image_width
    height = ratio < 1 ? (image_height * ratio).to_i : image_height

    { :width => width, :height => height }
  end

  private
    def get_metadata_for_linked_image(link)
      Rails.cache.fetch("remote_image_#{Digest::SHA1.hexdigest(link)}", :expires_in => 15.minutes) do
        image_attributes = { }
        Tempfile.open("remote_image", File.join(RAILS_ROOT, 'tmp')) do |tempfile|
          tempfile.write Net::HTTP.get(URI.parse(link))
          image_attributes = ImageScience.with_image(tempfile.path) { |image| { :width => image.width, :height => image.height } }
        end
        image_attributes
      end || { }
    rescue
      logger.debug "could not get image metadata for this url: #{link}"
      { }
    end
end


# Песня
class SongEntry < Entry
  validates_presence_of :data_part_1, :if => :no_attachment, :message => 'это обязательное поле'
  validates_format_of :data_part_1, :with => Format::HTTP_LINK, :if => :no_attachment, :message => 'ссылка должна быть на веб-сайт, т.е. начинаться с http://'
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LINK_LENGTH, :if => :no_attachment, :too_long => 'ссылка какая-то очень длинная'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'

  def entry_russian_dict; { :who => 'песня', :whom => 'песню' } end
  def can_have_attachments?; true; end

  def excerpt
    self.data_part_2.to_s.truncate(150).to_s
  end

  before_validation :make_a_link_from_data_part_1_if_present
end


# Встроенное видео, вроде youtube
#   data_part_1 - link / embed код
#   data_part_2 - описание
class VideoEntry < Entry
  validates_presence_of :data_part_1, :message => 'это обязательное поле'
#  validates_format_of :data_part_1, :with => Format::HTTP_LINK, :message => 'ссылка должна быть на веб-сайт, т.е. начинаться с http://'
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LENGTH, :on => :save, :too_long => 'ммм... код какой-то слишком длинный'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :on => :save, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'
  def entry_russian_dict; { :who => 'видео', :whom => 'видео' } end

  before_validation :make_a_link_from_data_part_1_if_present

  def excerpt
    self.data_part_2.to_s.truncate(150).to_s
  end

  def self.new_from_bm(params)
    if params[:c] && params[:c].downcase.starts_with?('<object')
      embed_or_url = params[:c]
      desc = "<a href='#{params[:url]}'>#{params[:title] || params[:url]}</a>"
    else
      embed_or_url = params[:url]
      desc = params[:c] || params[:title]
    end
    self.new :data_part_1 => embed_or_url, :data_part_2 => desc
  end

  # пытаемся подключить видео формат после того как видео было найдено
  def after_find
    self.metadata = {} if self.metadata.nil?
    if self.metadata[:video_module].blank?
      self.metadata[:video_module] = Video::detect_by_link(self.data_part_1)
      self.metadata_will_change!
    end
    self.extend self.metadata[:video_module].blank? ? Video::Unknown : self.metadata[:video_module].constantize
  end

  def data_part_1=(link)
    write_attribute(:data_part_1, link)
    unless link.blank?
      self.metadata = {} if self.metadata.nil?
      self.metadata[:video_module] = Video::detect_by_link(link)
      self.metadata_will_change!
      self.extend metadata[:video_module].blank? ? Video::Unknown : metadata[:video_module].constantize
    end
  end
end


class ConvoEntry < Entry
  validates_presence_of :data_part_1, :message => 'это обязательное поле'
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LENGTH, :on => :save, :too_long => 'ммм... слишком длинный диалог'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :on => :save, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'
  def entry_russian_dict; { :who => 'диалог', :whom => 'диалог' } end

  def excerpt
    self.data_part_1.to_s.truncate(150).to_s
  end
  def self.new_from_bm(params)
    self.new :data_part_1 => params[:c], :data_part_2 => params[:title]
  end
end


class CodeEntry < Entry
  validates_presence_of :data_part_1, :message => 'это обязательное поле'
  validates_length_of :data_part_1, :within => 1..ENTRY_MAX_LENGTH, :on  => :save, :too_long => 'ммм... слишком много кода'
  validates_length_of :data_part_2, :within => 0..ENTRY_MAX_LENGTH, :on => :save, :if => Proc.new { |e| !e.data_part_2.blank? }, :too_long => 'это поле слишком длинное'
  def entry_russian_dict; { :who => 'код', :whom => 'код' } end

  def excerpt
    self.data_part_1.to_s.truncate(150).to_s
  end
end
