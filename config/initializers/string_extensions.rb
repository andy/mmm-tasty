class String
  # Определяет если строка может являться OpenID URL идентификатором пользователя
  #  http://myopenid.com/profile/andy => true
  #  http://andy.livejournal.com/ => true
  #  my@email.com => false
  #  string => false
  def is_openid?
    return true if self.match(/^(http|https):\/\//i)
    return true if self.match(/^([a-z0-9\-]{1,30})\.(livejournal\.com|myopenid\.com)$/i)
    false
  end

  def escape_javascript
    (self || String.new).gsub('\\','\0\0').gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }
  end

  def truncate(length = 30, truncate_string = "...")
    if self.blank? then return end
    l = length - truncate_string.chars.length
    self.chars.length > length ? self.chars[0...l] + truncate_string : self
  end

  # Prevents SQL breakage by replacing each single quote with two
  def sequelize
    self.gsub("'", "''")
  end

  # same as with array
  # def to_query
  #   "'#{self.sequelize}'"
  # end

  def sql_quote
    ActiveRecord::Base.connection.quote(self)
  end

  class << self
    def random
      Digest::SHA1.hexdigest Time.now.to_s.split(//).sort_by { rand }.join
    end
  end
end
