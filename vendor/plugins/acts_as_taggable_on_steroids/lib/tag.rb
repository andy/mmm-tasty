class Tag < ActiveRecord::Base
  CLOUD_OPTIONS = {:max_rows => 50, :minimum_font_size => 1, :maximum_font_size => 6}

  has_many :taggings

  validates_presence_of :name
  validates_uniqueness_of :name

  class << self
    delegate :delimiter, :delimiter=, :to => TagList
  end

  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end

  def to_s
    name
  end

  def count
    read_attribute(:count).to_i
  end


  #
  # this code comes from markaboo
  #
  def Tag.cloud(options={}, &proc)
    options = CLOUD_OPTIONS.merge(options)
    cloud = []
    thresholds = {}
    categories = proc ? proc.call : all(options)

    unless categories.empty?
      max = categories.first.last
      min = categories.last.last
    end

    max ||= 1
    min ||= 10000000

    minLog = Math.log(min)
    maxLog = Math.log(max)

    delta = (maxLog == minLog) ? 1 : (maxLog - minLog)
    font_range = (options[:maximum_font_size] - options[:minimum_font_size])

    categories.each do |category|
      name, frequency = category

      relative_weight = (Math.log(frequency) - minLog) / delta
      font_size = (options[:minimum_font_size] + font_range * relative_weight).round
      cloud << [name, font_size, frequency]
    end

   	cloud.sort
  end

  def Tag.all(options ={})
    options = CLOUD_OPTIONS.merge(options)
    tags = []

    sql = <<-GO
      select tags.name, a.count_all
      from tags inner join (SELECT taggings.tag_id, COUNT(*) count_all
      FROM taggings
      GROUP BY taggings.tag_id
      order by count_all desc
      #{"LIMIT %d" % options[:max_rows] unless options[:max_rows].zero?}
      ) a on tags.id = a.tag_id
      order by a.count_all desc, tags.name asc
    GO

    result = connection.execute(sql.gsub("\n", ' ').squeeze(' '))
    result.each {|row| tags << [row[0], row[1].to_i]}

    tags
  end

  def Tag.find_all_by_user(person, include_private=false)
    Tag.find_by_sql("SELECT DISTINCT tags.* from tags INNER JOIN taggings on tags.id = taggings.tag_id INNER JOIN entries on taggings.taggable_id = entries.id WHERE #{'entries.is_private = 0 and' unless include_private} entries.user_id = #{person.id} order by tags.name")
  end
end
