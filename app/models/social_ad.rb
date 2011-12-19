class SocialAd < ActiveRecord::Base
  belongs_to :user
  belongs_to :entry

  validates_associated :user
  validates_associated :entry
  validates_length_of :annotation, :within => 3..128, :too_short => 'минимальная длина - 3 символа', :too_long => 'слишком длинная аннотация получилась... попробуйте сократить'

  # найти записи для отображения в рекламном блоке
  # пример:
  #  @ads = SocialAd.find_for_display(:all, { :user => current_user, :tlog => current_site })
  def self.find_for_view(method, options = {})
    options = { :limit => 3 }.update(options.symbolize_keys)
    user = options.key?(:user) ? options.delete(:user) : nil
    tlog = options.key?(:tlog) ? options.delete(:tlog) : nil
    skip_impressions = options.key?(:skip_impressions) ? options.delete(:skip_impressions) : nil

    conditions = ["#{self.table_name}.created_at > 0 AND #{self.table_name}.is_disabled = 0"]
    conditions << ["#{self.table_name}.user_id NOT IN (SELECT user_id FROM relationships WHERE reader_id = #{user.id} AND votes_value < -2) AND #{self.table_name}.user_id != #{user.id}"] if user
    conditions << ["#{self.table_name}.user_id != #{tlog.id}"] if tlog


    ads = self.with_scope(:find => { :conditions => conditions.join(' AND ')}) do
      find(method, options)
    end

    # увеличиваем счетчик показов если баннеры будут показыавться
    unless ads.empty?
      self.connection.update("UPDATE #{self.table_name} SET impressions = impressions + 1 WHERE id IN (#{ads.map(&:id).join(',')})")
      ads.each do |ad| ad.impressions += 1 end
    end

    ads
  end


  def click!
    self.connection.update("UPDATE #{self.class.table_name} SET clicks = clicks + 1 WHERE id = #{self.id}")
  end

  protected
    def validate
      errors.add('entry belongs to another user') unless user_id == entry.user_id
      # проверяем, имеет ли пользователь право заводить новую рекламную компанию?
    end
end
