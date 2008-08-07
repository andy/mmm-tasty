require 'openid'
require 'openid/extensions/sreg'
require 'openid/store/filesystem'
require 'mp3info'
# require 'format'
# require 'video'
# require 'string_ext'
require 'coderay'
require 'convoray'
# require 'paginator'

# require 'ruport'

require 'memcache_util'
CACHE = MemCache.new '127.0.0.1:3001', :namespace => RAILS_ENV

# http://dev.robotcoop.com/Libraries/cached_model/
# require 'cached_model'
# CachedModel::use_memcache = false
# CachedModel::ttl = 1.hour
# CachedModel::use_local_cache = true

# http://rails.techno-weenie.net/tip/2005/12/23/make_fixtures
ActiveRecord::Base.class_eval do
  # person.dom_id #-> "person-5"
  # new_person.dom_id #-> "person-new"
  # new_person.dom_id(:bare) #-> "new"
  # person.dom_id(:person_name) #-> "person-name-5"
  def dom_id(prefix=nil, postfix=nil)
    display_id = new_record? ? "new" : id
    prefix = prefix.to_s.underscore
    postfix = postfix.to_s.underscore
    # prefix ||= self.class.name.underscore
    # prefix != :bare ? "#{prefix.to_s.dasherize}-#{display_id}" : display_id
    ([prefix.blank? ? nil : prefix, self.class.name.underscore, display_id, postfix.blank? ? nil : postfix].compact * '_').tr('/-.', '_')
  end

  def referenced_cache_key
    "[#{[id, self.class.name] * ':'}]"
  end
end


class Time
  # возвращает true если даты - один день
  def same_day?(time)
    self.to_date == time.to_date
  end
  
  def today?
    self.to_date == Date.today
  end
  
  def to_timestamp_s
    "#{mday} #{month.to_rmonth} #{year}, #{hour}:#{min}"
  end
  
  # Time.now.distance_between_in_words(1.year.ago, ' спустя')
  def distance_between_in_words(dst, postfix = nil)
    seconds = (self.to_i - dst.to_i).abs
    case seconds
    when 0..60:
      "только что"
    when 1.minute..1.hour:
      "#{(seconds/1.minute).pluralize("минуту", "минуты", "минут", true)}#{postfix}"
    when 1.hour..1.day:
      "#{(seconds/1.hour).pluralize("час", "часа", "часов", true)}#{postfix}"
    when 1.day..1.week:
      "#{(seconds/1.day).pluralize("день", "дня", "дней", true)}#{postfix}"
    when 1.week..1.month:
      "#{(seconds/1.week).pluralize("неделю", "недели", "недель", true)}#{postfix}"
    else
      "#{(seconds/1.month).pluralize("месяц", "месяца", "месяцев", true)}#{postfix}"
    end
  end
end

class Fixnum
  def to_rwday
    %w( понедельник вторник среда четверг пятница суббота воскресенье )[self.to_i - 1]
  end
  
  def to_rmonth
    %w( января февраля марта апреля мая июня июля августа сентября октября ноября декабря )[self.to_i - 1]    
  end

  def to_rmonth_s
    %w( январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь )[self.to_i - 1]    
  end
  
  # Переворачивает адресацию в страницах. Первая становится последней, последняя - первой
  def reverse_page(total)
    return total + 1 - self.to_i if self.to_i > 0 && self.to_i <= total
    1
  end
  
  # Возвращает количетсво страниц если текущее число - общее количество записей, например:
  # Entry.count.to_pages
  def to_pages(per_page = 15)
    (self.to_i / per_page.to_f).ceil
  end

  # в булеан
  def to_b
    !!self.to_i
  end
end


class Array
  def shuffle
    self.sort { Kernel::rand(3) - 1 }
  end
  
  # def to_query
  #   self.collect {|t| t.class == Fixnum ? t : "'#{t.sequelize}'"}.join(', ')
  # end
end

# убираем param, который присутсвует в оригинальной версии. потому что иначе получается битый html когда
#  народ постит контент из ютуба.
module HTML
  class Tag
    # Returns non-+nil+ if this tag can contain child nodes.
    def childless?(xml = false)
      return false if xml && @closing.nil?
      !@closing.nil? ||
        @name =~ /^(img|br|hr|link|meta|area|base|basefont|
                    col|frame|input|isindex)$/ox
    end
  end
end

class Float  
  def to_csv
    "\"#{self.to_s.tr('.',',')}\""
  end
end